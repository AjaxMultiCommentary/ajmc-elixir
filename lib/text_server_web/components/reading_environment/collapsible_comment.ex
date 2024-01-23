defmodule TextServerWeb.ReadingEnvironment.CollapsibleComment do
  use TextServerWeb, :live_component

  alias TextServer.Comments.Comment
  alias TextServer.Commentaries.CanonicalCommentary

  alias TextServerWeb.CoreComponents

  attr :comment, :map, required: true
  attr :color, :string, default: "#fff"
  attr :current_user, Accounts.User
  attr :highlighted?, :boolean
  attr :is_iiif_viewer_shown, :boolean, default: false
  attr :is_open, :boolean, default: false

  def render(assigns) do
    ~H"""
    <div
      class={[
        "border-2 collapse collapse-arrow rounded-sm mb-2",
        if(@highlighted?, do: "border-secondary collapse-open", else: "")
      ]}
      id={@comment.interface_id}
    >
      <div class="collapse-title" phx-click="toggle-details" phx-target={@myself}>
        <h3 class="text-sm font-medium base-content cursor-pointer">
          <span class="text-sm font-light base-content">
            <%= citation(@comment.attributes) %>
          </span>
          <small class="mt-1 mx-w-2xl text-sm base-content">
            <.link navigate={~p"/bibliography/#{@comment.canonical_commentary.pid}"} class="hover:underline">
              <%= CanonicalCommentary.commentary_label(@comment.canonical_commentary) %>
            </.link>
          </small>
        </h3>
        <%= if match?(%Comment{}, @comment) do %>
          <small class="text-sm base-content">
            <%= @comment.attributes |> Map.get("lemma") %>
          </small>
        <% end %>
      </div>
      <div class="collapse-content float-right">
        <p class="max-w-2xl text-sm base-content font-serif"><%= @comment.content %></p>
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
              class="btn btn-xs btn-outline btn-secondary"
              phx-click="show-iiif-viewer"
              phx-target={@myself}
            >
              Show page image
            </CoreComponents.button>
          <% end %>
        </div>
        <%= unless is_nil(@current_user) do %>
          <small class="mt-1 text-xs base-content">
            <%= @comment.attributes["page_ids"] |> Enum.join(", ") %>

            <%= for {k, v} <- @comment.canonical_commentary.metadata do %>
              <p><%= k %>: <%= v %></p>
            <% end %>
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
    citations = attributes |> Map.get("citations")

    if Enum.at(citations, 0) != Enum.at(citations, 1) do
      "#{gettext("vv.")} #{Enum.join(citations, "–")}."
    else
      "#{gettext("v.")} #{List.first(citations)}."
    end
  end
end
