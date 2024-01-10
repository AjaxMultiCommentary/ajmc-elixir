defmodule TextServerWeb.CommentariesLive.Index do
  alias TextServerWeb.CoreComponents
  use TextServerWeb, :live_view

  alias TextServer.Commentaries

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
          <h1 class="text-base font-semibold leading-6 text-gray-900"><%= gettext("Bibliography") %></h1>
        </div>
      </div>
      <CoreComponents.table id="bibliography" rows={@commentaries} row_id={fn row -> "commentary_#{row.id}" end}>
        <:col :let={commentary} label={gettext("Creator(s)")}>
          <%= creators_to_string(commentary.creators) %>
        </:col>
        <:col :let={commentary} label={gettext("Title")}><%= commentary.title %></:col>
        <:col :let={commentary} label={gettext("Publication Date")}><%= commentary.publication_date %></:col>
        <:col :let={commentary} label={gettext("Public Domain?")}>
          <%= commentary.public_domain_year < NaiveDateTime.utc_now().year %>
        </:col>
        <:col :let={commentary} label={gettext("Languages")}>
          <%= commentary.languages |> Enum.join(", ") %>
        </:col>
      </CoreComponents.table>
    </section>
    """
  end

  defp creators_to_string(creators) when length(creators) == 1 do
    creator = creators |> List.first()

    "#{creator.last_name}, #{creator.first_name}"
  end

  defp creators_to_string(creators) when length(creators) > 1 do
    [creator | rest] = creators

    s = "#{creator.last_name}, #{creator.first_name}"

    last = List.last(rest)

    rest = (rest -- [last]) |> Enum.map(fn c -> "#{c.first_name} #{c.last_name}" end)

    "#{s}, #{Enum.join(rest, ",")}, and #{last.first_name} #{last.last_name}"
  end
end
