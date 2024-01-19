defmodule TextServerWeb.Components.MultiSelect do
  use TextServerWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="mt-1" id={"options-container-#{@id}"}>
      <%= inputs_for @form, :options, fn value -> %>
        <div class="px-2">
          <%= label(value, :label) do %>
            <%= checkbox(value, :selected,
              phx_change: "checked",
              phx_target: @myself,
              value: value.data.selected
            ) %>
            <%= value.data.label %> <span class="text-slate-500 float-right">(<%= value.data.count %>)</span>
          <% end %>
        </div>
      <% end %>
    </div>
    """
  end

  def update(params, socket) do
    %{options: options, form: form, selected: selected, id: id} = params

    socket =
      socket
      |> assign(:id, id)
      |> assign(:selected_options, filter_selected_options(options))
      |> assign(:options, options)
      |> assign(:form, form)
      |> assign(:selected, selected)

    {:ok, socket}
  end

  def handle_event("checked", %{"multi_select" => %{"options" => values}}, socket) do
    [{index, %{"selected" => selected?}}] = Map.to_list(values)
    index = String.to_integer(index)
    current_option = Enum.at(socket.assigns.options, index)

    updated_options =
      List.replace_at(socket.assigns.options, index, %{current_option | selected: selected?})

    socket.assigns.selected.(updated_options)

    {:noreply, socket}
  end

  defp filter_selected_options(options) do
    Enum.filter(options, fn opt -> opt.selected == true or opt.selected == "true" end)
  end
end
