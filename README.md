# Ajax Multi-Commentary 

This repository is a hard fork of the Open Commentaries' [main server](https://github.com/Open-Commentaries/open-commentaries) as of [fd2b294d1ff89a8d73aaeec53b316d31ce038572](https://github.com/Open-Commentaries/open-commentaries/commit/fd2b294d1ff89a8d73aaeec53b316d31ce038572).

## Development

### Environment variables:

In order to start the app locally, you will need to set a few
environment variables:

- `ZOTERO_API_URL`: for now, set it to something like https://api.zotero.org/groups/YOUR_GROUP_HERE, since Zotero prefixes most API queries by the user or group. (See https://www.zotero.org/support/dev/web_api/v3/basics.)
- `ZOTERO_API_TOKEN`: See https://www.zotero.org/settings/keys.

- For now, enable S3 uploads by proxying the MinIO server with `fly proxy 9000`.

## What are we doing?

We have canonical texts that have been digitized, and we have people who have been writing commentaries in formats that are not compatible with these digital versions. How do we fit these two things together?

Digital preservation and presentation.

## About the schema

We follow the [CTS URN spec](http://cite-architecture.github.io/ctsurn_spec/),
which can at times be confusing.

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

## Commentaries

Comments get as specific as possible (e.g., up to a specific lemma); but if that
fails, specificity falls back up the citation chain (e.g., on the specific
section in Pausanias).

## Funding

https://research.fas.harvard.edu/deans-competitive-fund-promising-scholarship


## TODO: Organize comparanda by version type (edition, translation, commentary)

## TODO: Sync to Dropbox

## TODO: Tagging

- Don't build into the interface
- Build into XML parser
- Hash tags and then Word/Open XML indexes
- We need to be able to add definitions for tags
  - make comments about tags themselves (build this into the interface)

## TODO: Blog posts

Allow writing blog posts on commentaries in progress

## TODO: Two-up view

Two panels with editions that can be synced. For example,
we can have the Pausanias translation alongside the
Pausanias commentary.

## TODO: oc.newalexandria.info -> opencommentaries.org pipeline

Migrate commentaries from oc.newalexandria to opencommentaries

## TODO (and notes)

- [ ] Scaife viewer-like URN navigation
- [ ] Alexandria 1.0--style comments
- Tags and/as index (#example-tag)
- Logging for error reports
- Anchor comments (ask for what these are) --- longer comments that fall under
  a given tag. Can be divided into parts, sorted by text location order
  when viewing a given tag's page.
- Named-entity recognition from Neil Smith and Chris Blackwell
- Mobile/responsive layout optimizations
- Global find-and-replace
- Version diffing (where in the pipeline?)
- Need to support uploading multiple docxs
- Show that so-and-so modified a text (important scholarly principle)
- Different approaches for translations, editions, and commentaries
  - Accommodate all three together, but don't enforce it
  - Translation could be secondary to edition and commentary
  - If the commentary is keyed to the original text (edition), translation is secondary
  - If the commentary is keyed to the translation, the edition is secondary
- Let the reader find the alignment between edition and translation
- Let the commenter point to a reference text
- Prioritize commentaries/comments --- just bring up comments
- Aim for most people to create translations and commentaries from scratch on the platform
- Use Perseus commentaries
  - Pre-ingest things to show what people can do on the platform

## TODO - Data from oc.newalexandria.info

- Pull in comments from A Pausanias Commentary in Progress
- Search functionality
- Tagging!

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix

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
