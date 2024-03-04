defmodule TextServerWeb.ReadingEnvironment.CollapsibleComment do
  alias TextServerWeb.Helpers.Markdown
  use TextServerWeb, :live_component

  alias TextServer.Comments.Comment
  alias TextServer.Commentaries.CanonicalCommentary

  alias TextServerWeb.CoreComponents

  attr :comment, :map, required: true
  attr :color, :string, default: "#fff"
  attr :current_user, Accounts.User
  attr :debug_info_shown?, :boolean, default: false
  attr :highlighted?, :boolean
  attr :iiif_viewer_shown?, :boolean, default: false
  attr :open?, :boolean, default: false
  attr :passage_urn, :map

  def render(assigns) do
    ~H"""
    <div
      class={[
        "border-2 collapse collapse-arrow rounded-sm mb-2",
        if(@highlighted?, do: "border-secondary collapse-open", else: ""),
        if(@open?, do: "collapse-open")
      ]}
      id={@comment.interface_id}
    >
      <div class="collapse-title" phx-click="toggle-details" phx-target={@myself}>
        <h3 class="text-sm font-medium base-content cursor-pointer">
          <span class="text-sm font-light base-content">
            <.link patch={~p"/versions/#{@passage_urn}?gloss=#{citable_gloss(@comment)}"}>
              <%= citation(@comment.attributes) %>
            </.link>
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
        <p class="max-w-2xl text-sm base-content font-serif decorate-links">
          <%= raw(Markdown.sanitize_and_parse_markdown(@comment.content)) %>
        </p>
        <div class="flex mt-2 justify-center">
          <%= if @iiif_viewer_shown? do %>
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
          <div class="flex mt-2 justify-center">
            <%= if @debug_info_shown? do %>
              <div>
                <small class="mt-1 text-xs base-content">
                  <%= @comment.attributes["page_ids"] |> Enum.join(", ") %>

                  <%= for {k, v} <- @comment.canonical_commentary.metadata do %>
                    <p><%= k %>: <%= v %></p>
                  <% end %>
                </small>
                <CoreComponents.button
                  type="button"
                  class="btn btn-xs btn-outline btn-warning"
                  phx-click="hide-debug-info"
                  phx-target={@myself}
                >
                  Hide debug info
                </CoreComponents.button>
              </div>
            <% else %>
              <CoreComponents.button
                type="button"
                class="btn btn-xs btn-outline btn-warning"
                phx-click="show-debug-info"
                phx-target={@myself}
              >
                Show debug info
              </CoreComponents.button>
            <% end %>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  def handle_event("toggle-details", _params, socket) do
    socket =
      if socket.assigns.highlighted? do
        send(self(), {:unhighlight_comment, socket.assigns.comment.interface_id})
        assign(socket, highlighted?: false, open?: false)
      else
        open? = Map.get(socket.assigns, :open?, false)

        assign(socket, :open?, !open?)
      end

    {:noreply, socket}
  end

  def handle_event("hide-debug-info", _, socket) do
    {:noreply, socket |> assign(:debug_info_shown?, false)}
  end

  def handle_event("show-debug-info", _, socket) do
    {:noreply, socket |> assign(:debug_info_shown?, true)}
  end

  def handle_event("show-iiif-viewer", _, socket) do
    {:noreply, socket |> assign(:iiif_viewer_shown?, true)}
  end

  defp citation(attributes) do
    citations = attributes |> Map.get("citations")

    if Enum.at(citations, 0) != Enum.at(citations, 1) do
      "#{gettext("vv.")} #{Enum.join(citations, "–")}."
    else
      "#{gettext("v.")} #{List.first(citations)}."
    end
  end

  defp citable_gloss(comment) do
    "#{comment.urn.work_component}:#{comment.urn.passage_component}"
  end
end
