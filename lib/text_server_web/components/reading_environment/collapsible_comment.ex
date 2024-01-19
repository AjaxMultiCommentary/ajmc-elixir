defmodule TextServerWeb.ReadingEnvironment.CollapsibleComment do
  use TextServerWeb, :live_component

  alias TextServer.Comments.Comment
  alias TextServer.Commentaries.CanonicalCommentary

  alias TextServerWeb.CoreComponents

  attr :comment, :map, required: true
  attr :color, :string, default: "#fff"
  attr :current_user, Accounts.User
  attr :is_highlighted, :boolean
  attr :is_iiif_viewer_shown, :boolean, default: false
  attr :is_open, :boolean, default: false

  def render(assigns) do
    ~H"""
    <div
      class={[
        "border-2 collapse collapse-arrow rounded-sm mb-2",
        if(@is_highlighted, do: "border-slate-800", else: ""),
        if(@is_open, do: "collapse-open", else: "collapse-close")
      ]}
      id={"comment-#{@comment.id}"}
    >
      <div class="collapse-title" phx-click="toggle-details" phx-target={@myself}>
        <h3 class="text-sm font-medium text-slate-900 cursor-pointer">
          <span class="text-sm font-light text-slate-600">
            <%= citation(@comment.attributes) %>
          </span>
          <small class="mt-1 mx-w-2xl text-sm text-slate-500">
            <.link navigate={~p"/bibliography/#{@comment.canonical_commentary.pid}"} class="hover:underline">
              <%= CanonicalCommentary.commentary_label(@comment.canonical_commentary) %>
            </.link>
          </small>
        </h3>
        <%= if match?(%Comment{}, @comment) do %>
          <small class="text-sm text-slate-700">
            <%= @comment.attributes |> Map.get("lemma") %>
          </small>
        <% end %>
      </div>
      <div class="collapse-content float-right">
        <p class="max-w-2xl text-sm text-slate-800"><%= @comment.content %></p>
        <div class="flex mt-2 justify-center">
          <%= if @is_iiif_viewer_shown do %>
            <.live_component
              id={"iiif-viewer-comment-#{@comment.id}"}
              module={TextServerWeb.Components.IiifViewer}
              comment={@comment}
            />
          <% else %>
            <CoreComponents.button
              type="button"
              class="rounded-sm bg-white px-2 py-1 text-xs font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50"
              phx-click="show-iiif-viewer"
              phx-target={@myself}
            >
              Show page image
            </CoreComponents.button>
          <% end %>
        </div>
        <%= unless is_nil(@current_user) do %>
          <small class="mt-1 text-xs text-slate-500">
            <%= @comment.attributes["page_ids"] |> Enum.join(", ") %>
          </small>
        <% end %>
      </div>
    </div>
    """
  end

  def handle_event("toggle-details", _, socket) do
    is_open = Map.get(socket.assigns, :is_open, false)

    {:noreply, socket |> assign(:is_open, !is_open)}
  end

  def handle_event("show-iiif-viewer", _, socket) do
    {:noreply, socket |> assign(:is_iiif_viewer_shown, true)}
  end

  defp citation(attributes) do
    citation = attributes |> Map.get("citation")

    if Enum.count(citation) > 1 do
      "#{gettext("vv.")} #{Enum.join(citation, "–")}."
    else
      "#{gettext("v.")} #{List.first(citation)}."
    end
  end
end
