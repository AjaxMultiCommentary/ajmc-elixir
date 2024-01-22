defmodule TextServerWeb.ReadingEnvironment.VersionCommandPalette do
  use TextServerWeb, :live_component

  alias TextServer.TextNodes.TextNode
  alias TextServer.Versions
  alias TextServerWeb.CoreComponents
  alias TextServerWeb.Icons

  def mount(socket) do
    {:ok,
     socket
     |> assign(
       changeset: to_form(TextNode.search_changeset(), as: :search),
       focused_index: 0,
       previewed_version_id: nil
     )}
  end

  def update(assigns, socket) do
    if assigns.urn && assigns.urn != Map.get(socket.assigns, :urn) do
      new_version = Versions.get_version_by_urn!(assigns.urn)

      {:ok,
       socket
       |> assign(assigns)
       |> assign(search_results: Versions.list_sibling_versions(new_version))}
    else
      {:ok, socket |> assign(assigns)}
    end
  end

  attr :changeset, :any
  attr :id, :any, required: true
  attr :is_open, :boolean, default: false
  attr :search_results, :list, default: []
  attr :urn, :string, required: true
  attr :version, TextServer.Versions.Version, default: nil

  def render(assigns) do
    # https://tailwindui.com/components/application-ui/navigation/command-palettes#component-5e859372042e1b3b308dc51f3ac8bad6
    ~H"""
    <div class={unless @is_open, do: "hidden"}>
      <div class="relative z-10" role="dialog" aria-modal="true">
        <!--
          Background backdrop, show/hide based on modal state.

          Entering: "ease-out duration-300"
            From: "opacity-0"
            To: "opacity-100"
          Leaving: "ease-in duration-200"
            From: "opacity-100"
            To: "opacity-0"
        -->
        <div class="fixed inset-0 bg-primary bg-opacity-25 transition-opacity"></div>

        <div class="fixed inset-0 z-10 overflow-y-auto p-4 sm:p-6 md:p-20">
          <!--
            Command palette, show/hide based on modal state.

            Entering: "ease-out duration-300"
              From: "opacity-0 scale-95"
              To: "opacity-100 scale-100"
            Leaving: "ease-in duration-200"
              From: "opacity-100 scale-100"
              To: "opacity-0 scale-95"
          -->
          <.focus_wrap
            id={"##{@id}-container"}
            class={~w(
              mx-auto
              max-w-3xl
              transform
              divide-y
              divide-primary
              overflow-hidden
              rounded-xl
              bg-white
              shadow-2xl
              ring-1
              ring-black
              ring-opacity-5
              transition-all
            )}
            phx-click-away="hide-version-command-palette"
            phx-target={@myself}
            phx-key="escape"
            phx-window-keydown="hide-version-command-palette"
          >
            <div class="relative">
              <Icons.search_icon />
              <.form for={@changeset} phx-change="search" phx-target={@myself}>
                <CoreComponents.basic_input
                  type="text"
                  field={@changeset[:version_search_string]}
                  class="h-12 w-full border-0 bg-transparent pl-11 pr-4 base-content placeholder:base-content focus:ring-0 sm:text-sm"
                  placeholder="Search for comparanda in other versions"
                  role="combobox"
                  aria-expanded="false"
                  aria-controls="options"
                  disabled="true"
                />
              </.form>
            </div>
            <!-- Empty state, show/hide based on command palette state -->
            <div :if={@search_results == []} class="px-6 py-14 text-center text-sm sm:px-14">
              <Icons.comparanda_icon />
              <p class="mt-4 font-semibold base-content">No comparanda found.</p>
              <p class="mt-2 base-content">We couldn&apos;t find anything with that term. Please try again.</p>
            </div>
            <div :if={@search_results != []} class="flex divide-x divide-primary">
              <!-- Preview Visible: "sm:h-96" -->
              <div class="max-h-96 min-w-0 flex-auto scroll-py-4 overflow-y-auto px-6 py-4 sm:h-96">
                <!-- Default state, show/hide based on command palette state. -->
                <h2 class="mb-4 mt-2 text-xs font-semibold base-content">Comparanda</h2>
                <ul class="-mx-2 text-sm base-content" id="page-command-palette_search-results" role="listbox">
                  <.list_item
                    :for={version <- @search_results}
                    active={@previewed_version_id == Integer.to_string(version.id)}
                    version={version}
                  />
                </ul>
              </div>
              <.preview version={
                Enum.find(@search_results, List.first(@search_results), fn tn ->
                  Integer.to_string(tn.id) == @previewed_version_id
                end)
              } />
            </div>
          </.focus_wrap>
        </div>
      </div>
    </div>
    """
  end

  attr :active, :boolean, default: false
  attr :version, :map, required: true

  def list_item(assigns) do
    ~H"""
    <!-- Active: "bg-primary base-content" -->
    <li
      class="group flex cursor-pointer select-none items-center rounded-md p-2 hover:bg-stone-200"
      id={"version_preview-#{@version.id}"}
      role="option"
      tabindex="-1"
      phx-click="preview-version"
      phx-value-version_id={@version.id}
      phx-target="#page-command-palette_search-results"
    >
      <section class="truncate">
        <h1 class="font-bold"><%= @version.label %></h1>
        <p class="flex-auto"><%= @version.urn %></p>
        <p class="base-content"><%= @version.description %></p>
      </section>
      <!-- Not Active: "hidden" -->
      <Icons.right_chevron :if={@active} />
    </li>
    """
  end

  attr :version, :map, required: true

  def preview(assigns) do
    ~H"""
    <!-- Active item side-panel, show/hide based on active state -->
    <div class="hidden h-96 w-1/2 flex-none flex-col divide-y divide-primary overflow-y-auto sm:flex">
      <div class="flex-none p-6 text-center">
        <h2 class="mt-3 font-semibold base-content"><%= @version.label %></h2>
        <h3 class="text-sm leading-6 base-content">
          <%= @version.urn %>
        </h3>
        <p class="text-sm leading-6 base-content"><%= @version.description %></p>
      </div>
      <div class="flex flex-auto flex-col justify-between p-6">
        <button
          type="button"
          class={~w(
              mt-6
              w-full
              sticky
              rounded-md
              bg-stone-600
              px-3
              py-2
              text-sm
              font-semibold
              text-white
              shadow-sm
              hover:bg-stone-500
              focus-visible:outline
              focus-visible:outline-2
              focus-visible:outline-offset-2
              focus-visible:outline-stone-600
            )}
          phx-click="select-sibling-version"
          phx-target="#reading-environment-reader"
          phx-value-version_id={@version.id}
        >
          Select
        </button>
      </div>
    </div>
    """
  end

  def handle_event("preview-version", %{"version_id" => id}, socket) do
    {:noreply, socket |> assign(previewed_version_id: id)}
  end

  def handle_event("hide-version-command-palette", _, socket) do
    send(self(), {:version_command_palette_open, false})
    {:noreply, socket}
  end
end
