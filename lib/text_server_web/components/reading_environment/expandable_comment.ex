defmodule TextServerWeb.ReadingEnvironment.ExpandableComment do
  use TextServerWeb, :live_component

  attr :comment, TextServer.TextElements.TextElement, required: true
  attr :shown, :boolean

  def render(assigns) do
    ~H"""
    <div class="grid grid-cols-2">
      <div>
        <h3 class="text-sm font-medium leading-6 text-gray-900">
          <%= @comment.attributes |> Map.get("lemma") %>
        </h3>
        <small class="mt-1 mx-w-2xl text-sm text-gray-500"><%= @comment.author %></small>
      </div>
      <div class={[unless(@shown, do: "hidden", else: "overflow-y-auto")]}>
        <p class="mt-1 max-w-2xl text-sm text-gray-800"><%= @comment.content %></p>
      </div>
    </div>
    """
  end
end
