defmodule TextServerWeb.CommentariesLive.Index do
  alias TextServerWeb.CoreComponents
  use TextServerWeb, :live_view

  alias TextServer.Commentaries

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(commentaries: list_commentaries())}
  end

  def render(assigns) do
    ~H"""
    <div class="px-4 sm:px-6 lg:px-8">
      <div class="sm:flex sm:items-center">
        <div class="sm:flex-auto">
          <h1 class="text-base font-semibold leading-6 text-gray-900">Bibliography</h1>
        </div>
      </div>
      <CoreComponents.table id="bibliography" rows={@commentaries} row_id={fn row -> "commentary_#{row.id}" end}>
        <:col :let={commentary} label="Author">
          <%= commentary.creator_first_name %> <%= commentary.creator_last_name %>
        </:col>
        <:col :let={commentary} label="Title"><%= commentary.title %></:col>
        <:col :let={commentary} label="Publication Date"><%= commentary.publication_date %></:col>
        <:col :let={_commentary} label="Public Domain?">More data required</:col>
        <:col :let={commentary} label="Languages">
          <%= commentary.languages |> Enum.join(", ") %>
        </:col>
      </CoreComponents.table>
    </div>
    """
  end

  defp list_commentaries do
    Commentaries.list_canonical_commentaries()
  end
end
