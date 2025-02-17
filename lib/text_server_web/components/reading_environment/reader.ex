defmodule TextServerWeb.ReadingEnvironment.Reader do
  use TextServerWeb, :live_component

  @moduledoc """
  Every screen of TextNodes can be represented as a map of
  List<nodes> and List<elements>.

  When these are rendered, the two lists are merged such that
  every `node` is split into a list where its text is interspersed
  with the starts and ends of `element`s.

  Essentially, this is a rope with the ability to store
  pointers to the `element`s list when an `element` starts
  and ends.

  In its deserialized form, the rope is a binary tree
  where each vertex stores a variable-length of text ---
  i.e., a text node --- its location, and a list of pointers
  to elements that need to be added to it. A node can be
  represented as its own subtree when elements need to be
  inserted into it.

  The rope is then serialized as a string of HTML for
  rendering.

  It should be possible to render a `node` and the `element`s
  "inside" it by splitting the `node`'s text at each `element`'s
  `offset`. If the `element` spans multiple `node`s, it can still
  visually apply to every `node` in between its start and end
  `nodes`.
  """

  attr :highlighted_comments, :list, default: []
  attr :lemmaless_comments, :list, default: []
  attr :personae_loquentes, :map, default: %{}
  attr :show_heatmap, :boolean, default: true
  attr :text_nodes, :list, required: true
  attr :version_urn, :string, required: true

  def render(assigns) do
    ~H"""
    <article id="reading-environment-reader">
      <section id="reading-page" class="leading-normal">
        <.live_component
          :for={text_node <- @text_nodes}
          module={TextServerWeb.ReadingEnvironment.TextNode}
          highlighted_comments={@highlighted_comments}
          lemmaless_comments={
            @lemmaless_comments
            |> Enum.filter(fn c ->
              first_citation = List.first(c.urn.citations)
              location = List.first(text_node.location)

              location == first_citation
            end)
          }
          id={text_node.id}
          persona_loquens={Map.get(@personae_loquentes, text_node.offset)}
          show_heatmap={@show_heatmap}
          text_node={text_node}
        />
      </section>
    </article>
    """
  end
end
