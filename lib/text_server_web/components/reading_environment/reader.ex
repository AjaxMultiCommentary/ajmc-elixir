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

  alias TextServer.TextNodes
  alias TextServer.Versions
  alias TextServerWeb.Components

  def mount(socket) do
    {:ok, socket |> assign(sibling_nodes: %{})}
  end

  attr :focused_text_node, :any, default: nil
  attr :version_command_palette_open, :boolean, default: false
  attr :sibling_nodes, :map, default: %{}
  attr :text_nodes, :list, required: true
  attr :text_node_command_palette_open, :boolean, default: false
  attr :version_urn, :string, required: true

  def render(assigns) do
    ~H"""
    <article id="reading-environment-reader">
      <section id="reading-page" class="text-xl leading-normal">
        <.live_component
          :for={text_node <- @text_nodes}
          module={TextServerWeb.ReadingEnvironment.TextNode}
          id={text_node.id}
          is_focused={is_focused(@focused_text_node, text_node)}
          sibling_node={@sibling_nodes |> Map.get(text_node.location)}
          text_node={text_node}
        />
      </section>
      <Components.footnotes footnotes={@footnotes} />
    </article>
    """
  end

  def handle_event("select-sibling-node", %{"text_node_id" => id}, socket) do
    new_sibling = TextNodes.get_text_node!(id) |> TextNodes.tag_text_node()

    send(self(), {:focused_text_node, nil})

    {:noreply,
     socket
     |> assign(
       sibling_nodes: Map.put(socket.assigns.sibling_nodes, new_sibling.location, new_sibling),
       text_node_command_palette_open: false
     )}
  end

  def handle_event("select-sibling-version", %{"version_id" => id}, socket) do
    version = Versions.get_version!(id)
    start_location = List.first(socket.assigns.text_nodes) |> Map.get(:location)
    end_location = List.last(socket.assigns.text_nodes) |> Map.get(:location)

    new_siblings =
      TextNodes.list_text_nodes_by_version_between_locations(
        version,
        start_location,
        end_location
      )
      |> TextNodes.tag_text_nodes()
      |> Map.new(fn tn ->
        {tn.location, tn}
      end)

    send(self(), {:version_command_palette_open, false})

    {:noreply, socket |> assign(sibling_nodes: new_siblings)}
  end

  def handle_event("show-version-command-palette", _, socket) do
    send(self(), {:version_command_palette_open, true})
    {:noreply, socket}
  end

  defp is_focused(focused_text_node, _text_node) when is_nil(focused_text_node) do
    false
  end

  defp is_focused(focused_text_node, text_node) do
    focused_text_node == text_node
  end
end
