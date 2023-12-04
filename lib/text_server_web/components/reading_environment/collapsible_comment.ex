defmodule TextServerWeb.ReadingEnvironment.CollapsibleComment do
  use TextServerWeb, :live_component

  attr :comment, :map, required: true
  attr :is_highlighted, :boolean

  def render(assigns) do
    IO.inspect(assigns.comment)

    ~H"""
    <details class={[
      "border-2 collapse collapse-arrow rounded-md mb-2",
      if(@is_highlighted, do: "border-stone-800", else: "")
    ]}>
      <input type="checkbox" class="min-h-0" />
      <summary class="collapse-title">
        <h3 class="text-md font-medium leading-6 text-gray-900">
          <%= @comment.attributes |> Map.get("lemma") %>
        </h3>
        <small class="mt-1 mx-w-2xl text-sm text-gray-500"><%= @comment.author %></small>
      </summary>
      <div class="collapse-content float-right">
        <p class="mt-1 max-w-2xl text-sm text-gray-800"><%= @comment.content %></p>
      </div>
    </details>
    """
  end
end
