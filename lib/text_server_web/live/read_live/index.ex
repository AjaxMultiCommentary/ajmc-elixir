defmodule TextServerWeb.ReadLive.Index do
  use TextServerWeb, :live_view

  alias TextServer.Collections
  alias TextServer.Collections.Collection
  alias TextServer.TextGroups
  alias TextServer.TextGroups.TextGroup
  alias TextServer.Versions
  alias TextServer.Versions.Version
  alias TextServer.Works
  alias TextServer.Works.Work

  alias TextServerWeb.Components

  def mount(params, _session, socket) do
    {:ok, apply_action(socket, socket.assigns.live_action, params)}
  end

  def handle_params(params, _uri, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-2xl px-4 py-16 sm:px-6 sm:py-24 lg:max-w-7xl lg:px-8">
      <h2 class="text-xl font-bold text-stone-900"><%= @heading %></h2>

      <ul role="list" class="divide-y divide-gray-200 sm:max-w-lg">
        <Components.search_list :let={item} items={@items}>
          <Components.search_list_item description={get_description(item)} title={get_title(item)} url={get_url(item)} />
        </Components.search_list>
      </ul>

      <.pagination items={@items} />
    </div>
    """
  end

  def pagination(%{items: %Scrivener.Page{}} = assigns) do
    ~H"""
    <Components.pagination current_page={@items.page_number} total_pages={@items.total_pages} />
    """
  end

  def pagination(assigns) do
    ~H"""
    <span />
    """
  end

  defp apply_action(socket, :index, params) do
    socket
    |> assign(:heading, "Collections")
    |> assign(:items, list_collections(params))
  end

  defp apply_action(socket, :collection, %{"collection" => collection} = assigns) do
    page_number = Map.get(assigns, "page", 1)

    socket
    |> assign(:heading, "Text Groups")
    |> assign(:items, list_text_groups(collection, page: page_number))
  end

  defp apply_action(
         socket,
         :text_group,
         %{"collection" => collection, "text_group" => text_group} = assigns
       ) do
    page_number = Map.get(assigns, "page", 1)

    socket
    |> assign(:heading, "Works")
    |> assign(:items, list_works(collection, text_group, page: page_number))
  end

  defp apply_action(
         socket,
         :work,
         %{"collection" => collection, "text_group" => text_group, "work" => work} = assigns
       ) do
    page_number = Map.get(assigns, "page", 1)

    socket
    |> assign(:heading, "Versions")
    |> assign(:items, list_versions(collection, text_group, work, page: page_number))
  end

  defp get_description(%Collection{} = item), do: CTS.URN.to_string(item.urn)
  defp get_description(%TextGroup{} = item), do: CTS.URN.to_string(item.urn)
  defp get_description(%Work{} = item), do: item.description || CTS.URN.to_string(item.urn)
  defp get_description(%Version{} = item), do: item.description || CTS.URN.to_string(item.urn)

  defp get_title(%Collection{} = item), do: item.title
  defp get_title(%TextGroup{} = item), do: item.title
  defp get_title(%Work{} = item), do: item.title
  defp get_title(%Version{} = item), do: item.label

  defp get_url(%Collection{} = item), do: ~p"/read/#{item.urn.namespace}"
  defp get_url(%TextGroup{} = item), do: ~p"/read/#{item.urn.namespace}/#{item.urn.text_group}"

  defp get_url(%Work{} = item),
    do: ~p"/read/#{item.urn.namespace}/#{item.urn.text_group}/#{item.urn.work}"

  defp get_url(%Version{} = item),
    do:
      ~p"/read/#{item.urn.namespace}/#{item.urn.text_group}/#{item.urn.work}/#{item.urn.version}"

  defp list_collections(_params) do
    Collections.list_collections_with_repositories()
  end

  defp list_text_groups(collection, opts) do
    TextGroups.list_text_groups_for_namespace(collection, opts)
  end

  defp list_works(collection, text_group, opts) do
    Works.list_works_for_urn(collection, text_group, opts)
  end

  defp list_versions(collection, text_group, work, opts) do
    Versions.list_versions_for_urn(
      CTS.URN.parse("urn:cts:#{collection}:#{text_group}.#{work}"),
      opts
    )
  end
end
