defmodule TextServerWeb.TextNodeLive.Show do
  use TextServerWeb, :live_view

  alias TextServer.TextNodes

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  attr :text_node, TextServer.TextNodes.TextNode, required: true

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-8">
      <.live_component
        module={TextServerWeb.ReadingEnvironment.TextNode}
        id={:text_node}
        sibling_node={nil}
        text_node={@text_node}
      />
    </div>
    """
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    text_node = TextNodes.get_text_node!(id)
    text_node = TextNodes.tag_text_nodes([text_node])

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:text_node, text_node)}
  end

  defp page_title(:show), do: "Show Text node"
  defp page_title(:edit), do: "Edit Text node"
end
