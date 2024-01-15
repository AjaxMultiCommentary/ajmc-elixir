# Ajax Multi-Commentary 

This repository is a hard fork of the Open Commentaries' [main server](https://github.com/Open-Commentaries/open-commentaries) as of [fd2b294d1ff89a8d73aaeec53b316d31ce038572](https://github.com/Open-Commentaries/open-commentaries/commit/fd2b294d1ff89a8d73aaeec53b316d31ce038572).

## Environment variables

In order to start the app locally, you will need to set a few
environment variables:

- `ZOTERO_API_URL`: for now, set it to something like https://api.zotero.org/groups/YOUR_GROUP_HERE, since Zotero prefixes most API queries by the user or group. (See https://www.zotero.org/support/dev/web_api/v3/basics.)
- `ZOTERO_API_TOKEN`: See https://www.zotero.org/settings/keys.

In production, a few additional variables are required:

- `DATABASE_URL`: For example: postgres://USER:PASS@HOST/DATABASE
- `SECRET_KEY_BASE`: For signing cookies etc.
- `PHX_HOST`: The hostname of the application. ajmc.unil.ch for now. Note that, even though the Phoenix server will not be talking to the outside world directly (all traffic goes through a proxy), it still needs to know what hostname to expect in requests so that it can respond properly.
- `PORT`: The local port for the server. This is where you'll send the proxied requests to, so if the proxy is serving the app at https://ajmc.unil.ch:443, it should proxy requests to something like http://127.0.0.1:4000.

## Deployment

This application is deployed using an Elixir [Release](https://hexdocs.pm/mix/1.15/Mix.Tasks.Release.html) that is built and deployed via a Docker container. The container's specification can be found in the [Dockerfile](./Dockerfile). Note the (very simple) [Dockerfile.postgres](./Dockerfile.postgres) as well: an example of using it can be found in [docker-compose.yaml](./docker-compose.yaml).

(Note that this docker-compose file is not used in production, but is rather a development convenience for debugging deployment issues.)

### Production server configuration

All of the configuration for the production Phoenix/Cowboy endpoint can be found in [config/runtime.exs](./config/runtime.exs). Note that HTTPS is not enforced at the application level. Instead, the expectation is that the application only allows local access, which is brokered to the outside world by a reverse proxy such as nginx. Bear in mind that the proxy needs to allow websocket connections in order for [LiveView](https://hexdocs.pm/phoenix_live_view/welcome.html) to work.


## Building

The Dockerfile builds a release of the Elixir application in a fairly standard way, but we also need to seed the database with the latest textual data about the Ajax commentaries.

To perform this seeding, [entrypoint.sh](./entrypoint.sh) runs `/app/bin/text_server eval "TextServer.Release.seed_database"`. This function starts the application processes (except for the HTTP server) and calls [`TextServer.Ingestion.Ajmc.run/0`](./lib/text_server/ingestion/ajmc.ex).

`TextServer.Ingestion.Ajmc.run/0` _deletes all of the existing comments and commentaries_: the data have the potential to change in difficult-to-reconcile ways, so it's easier just to start fresh, since we store the source files locally (more on that in a second).

`TextServer.Ingestion.Ajmc.run/0` then creates the `Version`s (= editions) of the critical text (Sophocles' _Ajax_), as detailed in [`TextServer.Ingestion.Versions`](./lib/text_server/ingestion/versions.ex).


### Versions [`TextServer.Ingestion.Versions`](./lib/text_server/ingestion/versions.ex)

These Versions are CTS-compliant editions of the text, meaning that they all descend from the same Work, which is identified by the URN urn:cts:greekLit:tlg0011.tlg003. Right now, we're only making one Version, based on Greg Crane's TEI XML encoding of Lloyd-Jones 1994's OCT. Eventually, we will ingest more editions into the same format.

The data structure for representing a text is essentially an ordered list of `TextNode`s. We need to keep the order (found at the `offset` property internally) even though each `TextNode` also has a `location` because the locations do not necessarily match textual order: lines can be transposed, for example, so that the reading order of lines 5, 6, and 7 might actually be 6, 5, 7. To take a real example, the lines 1028–1039 are bracketed in some editions and arguably should be excluded from the text. That would mean a jump from 1027 to 1040 -- still properly ordered, but irreconcilable across editions without individual ordering.

_Caveat lector: the following might change_

Each `TextNode` can be broken down further into an ordered list of graphemes. (We use graphemes and not characters in order to simplify handling polytonic Greek combining characters.) Annotations typically refer to lemmata as the range of graphemes that correspond to the word tokens of a given lemma. That means that instead of the CTS standard `urn:cts:greekLit:tlg0011.tlg003.ajmc-fin:1034@Ἐρινὺς`, we would refer to the grapheme range at `urn:cts:greekLit:tlg0011.tlg003.ajmc-fin:1034@7-12`.

This approach, however, should likely change, decomposing each edition to its `TextToken`s. This transition is a work in progress.

### Commentaries

Once the `Version`s have been ingested, we ingest each of the commentaries detailed in the [commentaries.toml](./priv/commentaries.toml). Their source files can be found with the glob pattern `priv/static/json/*_tess_retrained.json`. (_Nota bene_: Eventually we will need to move these files elsewhere, as we can only store public domain content in this repository.)

Each `CanonicalCommentary` pulls its data from Zotero by mapping the `id` from the corresponding tess_retrained.json to its accompanying `zotero_id`.

Each `CanonicalCommentary` has two kinds of comments: `Comment`s, which have a `word-anchor` and thus a lemma, and `LemmalessComments`, which have a `scope-anchor` (a range of lines).

Each `Comment` is mapped to its corresponding tokens in `urn:cts:greekLit:tlg0011.tlg003.ajmc-lj`; each `LemmalessComment` is mapped to the corresponding lines.

Note that sometimes these mappings will producde nonsensical results: Weckleinn, for instance, reorders the words in line 4, so his `Comment` on that line has a lemma ("ἔνθα Αἴαντος ἐσχάτην τάξιν ἔχει") that does not correspond to the text ("Αἴαντος, ἔνθα τάξιν ἐσχάτην ἔχει") — and this is a relatively minor discrepancy.

This is why it's important that we also allow readers to change the "base" or critical text and to apply the comments in a flexible way.

#### Rendering comments in the reader

We render the lemma of comments as a heatmap over the critical text in the reading environment, allowing readers to see at a glance when lines have been heavily glossed. To do so, we borrow approaches from the OOXML specification and ProseMirror:

We need to group the graphemes of each text node (line of _Ajax_) with the elements that should apply (we’re also preserving things like cruces and editorial insertions), including comments.

Starting by finding the comments that apply to a given line:

```elixir    
# comment starts with this text node OR
# comment ends on this text node OR
# text node is in the middle of a multi-line comment
comment.start_text_node_id == text_node.id or
  comment.end_text_node_id == text_node.id or
  (comment.start_text_node.offset <= text_node.offset and
      text_node.offset <= comment.end_text_node.offset)
```

we then check each grapheme to see if one of those comments applies:

```elixir
cond do
  # comment applies only to this text node
  c.start_text_node == c.end_text_node ->
    i in c.start_offset..(c.end_offset - 1)

  # comment starts on this text_node
  c.start_text_node == text_node ->
    i >= c.start_offset

  # comment ends on this text node
  c.end_text_node == text_node ->
    i <= c.end_offset

  # entire text node is in this comment
  true ->
    true
end
```

with that information (packaged in an admittedly confusing tuple of graphemes and tags), we can linearly render the text as a series of “grapheme blocks” with their unique tag sets:

```elixir 
<.text_element 
  :for={{graphemes, tags} <- @text_node.graphemes_with_tags} 
  tags={tags} text={Enum.join(graphemes)} 
/>
```

It remains to be determined how we will work with comments that don't match the underlying critical text.

## About the schema

We follow the [CTS URN spec](http://cite-architecture.github.io/ctsurn_spec/), which can at times be confusing.

Essentially, every `collection` (which is roughly analogous to a git repository)
contains one or more `text_group`s. It can be helpful to think of each
`text_group` as an author, but remember that "author" here designates not a
person but rather a loose grouping of works related by style, content, and
(usually) language. Sometimes the author is "anonymous" or "unknown" --- hence
`text_group` instead of "author".

Each `text_group` contains one or more `work`s. You might think of these as
texts, e.g., "Homer's _Odyssey_" or "Lucan's _Bellum Civile_".

A `work` can be further specified by a `version` URN component that points to
either an `edition` (in the traditional sense of the word) or a `translation`.

So in rough database speak:

- A `version` has a type indication of one of `commentary`, `edition`, or `translation`
- A `version` belongs to a `work`
- A `work` belongs to a `text_group`
- A `text_group` belongs to a `collection`

In reverse:

- A `collection` has many `text_group`s
- A `text_group` has many `work`s
- A `work` has many `version`s,
  each of which is typed as `commentary`, `edition`, or `translation`

Note that the [CTS specification](http://cite-architecture.github.io/cts_spec/) allows for
an additional level of granularity known as `exemplar`s. In our experience, creating
exemplars mainly introduced unnecessary redundancy with versions, so we have
opted not to include them in our API. See also http://capitains.org/pages/vocabulary.

## Running in development

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Make sure your configuration ([./config](./config)) is correct
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Front-end environment and development

We're leveraging Phoenix LiveView as much as possible for the front-end, but
occasionally we need modern niceties for CSS and JS. If you need to install a
dependency:

1. Think very carefully.
2. Do we really need this dependency?
3. What happens if it breaks?
4. Can we just use part of the dependency in the `vendor/` directory with proper attribution?
5. If you really must install a dependency --- like `@tailwindcss/forms` --- run `npm i -D <dependency>`
from within the `assets/` directory.

## Acknowledgments

Data and application code in this repository were produced in the context of the Ajax Multi-Commentary project, funded by the Swiss National Science Foundation under an Ambizione grant [PZ00P1_186033](https://data.snf.ch/grants/grant/186033).

Contributors: Carla Amaya (UNIL), Sven Najem-Meyer (EPFL), Charles Pletcher (UNIL), Matteo Romanello (UNIL), Bruce Robertson (Mount Allison University).

# License

    Open Commentaries: Collaborative, cutting-edge editions of ancient texts
    Copyright (C) 2022 New Alexandria Foundation

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
