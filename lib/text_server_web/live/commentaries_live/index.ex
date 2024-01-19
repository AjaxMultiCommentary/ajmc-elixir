defmodule TextServerWeb.CommentariesLive.Index do
  alias TextServerWeb.CoreComponents
  use TextServerWeb, :live_view

  alias TextServer.Commentaries
  alias TextServer.Commentaries.CanonicalCommentary

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(commentaries: Commentaries.list_commentaries())}
  end

  def render(assigns) do
    ~H"""
    <section>
      <div class="sm:flex sm:items-center">
        <div class="sm:flex-auto">
          <h1 class="text-base font-semibold leading-6 text-slate-900"><%= gettext("Bibliography") %></h1>
        </div>
      </div>
      <CoreComponents.table id="bibliography" rows={@commentaries} row_id={fn row -> "commentary_#{row.id}" end}>
        <:col :let={commentary} label={gettext("Creator(s)")}>
          <%= CanonicalCommentary.creators_to_string(commentary.creators) %>
        </:col>
        <:col :let={commentary} label={gettext("Title")}>
          <.link navigate={~p"/bibliography/#{commentary.pid}"}><%= commentary.title %></.link>
        </:col>
        <:col :let={commentary} label={gettext("Publication Date")}><%= commentary.publication_date %></:col>
        <:col :let={commentary} label={gettext("Public Domain?")}>
          <%= commentary.public_domain_year < NaiveDateTime.utc_now().year %>
        </:col>
        <:col :let={commentary} label={gettext("Languages")}>
          <%= commentary.languages |> Enum.join(", ") %>
        </:col>
        <:col :let={commentary} label="Wikidata">
          <.link href={"https://wikidata.org/wiki/#{commentary.wikidata_qid}"}>
            <%= commentary.wikidata_qid %>
          </.link>
        </:col>
      </CoreComponents.table>
    </section>
    """
  end
end
