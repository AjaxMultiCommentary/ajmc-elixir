defmodule TextServerWeb.ExemplarLive.New do
  use TextServerWeb, :live_view

  alias TextServer.Exemplars.Exemplar
  alias TextServer.Projects
  alias TextServer.Repo
  alias TextServer.TextGroups
  alias TextServer.Works

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(
       exemplar: %Exemplar{} |> Repo.preload(:language),
       page_title: "Create exemplar",
       project: get_project!(params["id"]),
       selected_work: nil,
       works: []
     )}
  end

  @impl true
  def handle_params(_params, _, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("search_works", %{"value" => search_string}, socket) do
    page = Works.search_works(search_string)
    works = page.entries
    text_groups = TextGroups.search_text_groups(search_string)
    text_group_works = Enum.flat_map(text_groups, & &1.works)
    works = Enum.concat(works, text_group_works)
    IO.inspect(Enum.map(works, & &1.english_title))
    selected_work = Enum.find(works, fn w -> w.english_title == search_string end)

    if is_nil(selected_work) do
      {:noreply, socket |> assign(:works, works)}
    else
      {:noreply, socket |> assign(:works, []) |> assign(:selected_work, selected_work)}
    end
  end

  def handle_event("reset_work_search", _params, socket) do
    {:noreply, socket |> assign(:works, []) |> assign(:selected_work, nil)}
  end

  defp get_project!(id) do
    Projects.get_project!(id)
  end
end
