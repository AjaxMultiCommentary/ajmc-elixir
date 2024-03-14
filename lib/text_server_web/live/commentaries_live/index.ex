defmodule TextServerWeb.CommentariesLive.Index do
  use TextServerWeb, :live_view

  alias TextServer.Commentaries
  alias TextServer.Commentaries.CanonicalCommentary
  alias TextServerWeb.CoreComponents
  alias TextServerWeb.Icons

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(commentaries: Commentaries.list_commentaries())
     |> assign(page_title: "– Bibliography")}
  end

  def render(assigns) do
    ~H"""
    <section>
      <div class="sm:flex sm:items-center">
        <div class="sm:flex-auto">
          <h1 class="text-base font-semibold leading-6 base-content"><%= gettext("Bibliography") %></h1>
        </div>
      </div>
      <CoreComponents.table id="bibliography" rows={@commentaries} row_id={fn row -> "commentary_#{row.id}" end}>
        <:col :let={commentary} label={gettext("Creator(s)")}>
          <%= CanonicalCommentary.creators_to_string(commentary.creators) %>
        </:col>
        <:col :let={commentary} label={gettext("Publication Date")}><%= commentary.publication_date %></:col>
        <:col :let={commentary} label={gettext("Title")}>
          <.link navigate={~p"/bibliography/#{commentary.pid}"}><%= commentary.title %></.link>
        </:col>
        <:col :let={commentary} label={gettext("Edition")}><%= commentary.edition %></:col>
        <:col :let={commentary} label={gettext("Place")}><%= commentary.place %></:col>
        <:col :let={commentary} label={gettext("Publisher")}><%= commentary.publisher %></:col>
        <:col :let={commentary} label={gettext("Public Domain?")}>
          <%= if commentary.public_domain_year < NaiveDateTime.utc_now().year do %>
            <Icons.lock_open />
          <% else %>
            <Icons.lock_closed />
          <% end %>
        </:col>
        <:col :let={commentary} label={gettext("Languages")}>
          <%= commentary.languages |> Enum.join(", ") %>
        </:col>
        <:col :let={commentary} label="Zotero">
          <.link href={commentary.zotero_link} class="link hover:opacity-80">
            <%= gettext("More bibliographic info") %>
          </.link>
        </:col>
        <:col :let={commentary} label="Wikidata">
          <.link href={"https://wikidata.org/wiki/#{commentary.wikidata_qid}"} class="link hover:opacity-80">
            <%= commentary.wikidata_qid %>
          </.link>
        </:col>
      </CoreComponents.table>
    </section>
    """
  end
end
