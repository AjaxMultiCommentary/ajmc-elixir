defmodule TextServerWeb.ReadLive.Reader do
  require Logger
  use TextServerWeb, :live_view

  alias TextServer.Repo
  alias TextServer.Versions
  alias TextServer.Versions.Passages
  alias TextServer.Versions.XmlDocuments

  alias TextServerWeb.ReadLive.Reader.Navigation
  alias TextServerWeb.ReadLive.Reader.Passage

  def mount(
        %{
          "collection" => collection_s,
          "text_group" => text_group_s,
          "work" => work_s,
          "version" => version_s
        } = params,
        _session,
        socket
      ) do
    current_page = Map.get(params, "page", "1") |> String.to_integer()

    version =
      get_version_by_urn!("urn:cts:#{collection_s}:#{text_group_s}.#{work_s}.#{version_s}")
      |> Repo.preload(commentaries: :lemmas)

    {:ok,
     socket
     |> assign(
       active_commentaries: [],
       current_page: current_page,
       version: version
     )}
  end

  def handle_params(params, _uri, socket) do
    assigns = Map.get(socket, :assigns)
    version = Map.get(assigns, :version)
    current_page = Map.get(assigns, :current_page)

    if is_nil(version.xml_document) do
      version =
        Versions.list_sibling_versions(version)
        |> Repo.preload(:xml_document)
        |> Enum.find(fn v -> !is_nil(v.xml_document) end)

      collection_s = Map.get(params, "collection")
      text_group_s = Map.get(params, "text_group")
      work_s = Map.get(params, "work")

      {:noreply,
       push_patch(
         socket |> assign(:version, version),
         to:
           ~p"/read/#{collection_s}/#{text_group_s}/#{work_s}/#{version.urn.version}?page=#{current_page}"
       )}
    else
      document = version.xml_document

      {:ok, refs_decl} = XmlDocuments.get_refs_decl(document)
      {:ok, toc} = XmlDocuments.get_table_of_contents(document, refs_decl)
      {:ok, passage_refs} = Passages.list_passage_refs(toc)

      passage_ref = Enum.at(passage_refs, current_page - 1, :all)

      {:ok, passage} = XmlDocuments.get_passage(document, refs_decl, passage_ref)

      {:noreply,
       socket
       |> assign(
         passage: passage |> Enum.join(""),
         passage_refs:
           passage_refs |> Enum.with_index(1) |> Enum.chunk_by(&(elem(&1, 0) |> elem(0))),
         refs_decl: refs_decl,
         toc: toc,
         unit_labels: refs_decl.unit_labels
       )}
    end
  end

  def handle_event("toggle-active-commentary", %{"commentary_id" => id}, socket) do
    id = String.to_integer(id)
    active_commentaries = socket.assigns.active_commentaries

    if Enum.member?(active_commentaries, id) do
      {:noreply,
       socket
       |> assign(:active_commentaries, Enum.reject(active_commentaries, &(&1 == id)))}
    else
      {:noreply, socket |> assign(:active_commentaries, [id | active_commentaries])}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="flex grow gap-y-5 overflow-y-auto px-6">
      <Navigation.navigation_menu current_page={@current_page} passage_refs={@passage_refs} unit_labels={@unit_labels} />
      <div class="p-6">
        <div>
          <%= for commentary <- @version.commentaries do %>
            <button
              class={["btn btn-primary", unless(Enum.member?(@active_commentaries, commentary.id), do: "btn-outline")]}
              phx-click="toggle-active-commentary"
              phx-value-commentary_id={commentary.id}
            >
              <%= commentary.pid %>
            </button>
          <% end %>
        </div>
        <div class="grid grid-cols-2">
          <div>
            <.live_component
              id={:reader_passage}
              module={Passage}
              lemmas={
                Enum.filter(@version.commentaries, fn c -> Enum.member?(@active_commentaries, c.id) end)
                |> Enum.flat_map(& &1.lemmas)
              }
              passage={@passage}
            />
          </div>
          <div id="iiif-viewer" phx-hook="IIIFHook" class="openseadragon" style="width: 800px; height: 600px;" />
        </div>
      </div>
    </div>
    """
  end

  defp get_version_by_urn!(urn_s) do
    Versions.get_version_by_urn!(urn_s) |> Repo.preload(:xml_document)
  end
end
