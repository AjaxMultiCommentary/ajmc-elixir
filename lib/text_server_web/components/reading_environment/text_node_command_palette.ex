defmodule TextServerWeb.ReadingEnvironment.TextNodeCommandPalette do
  use TextServerWeb, :live_component

  alias TextServer.TextNodes
  alias TextServer.TextNodes.TextNode
  alias TextServerWeb.CoreComponents
  alias TextServerWeb.Icons

  @moduledoc """
  TODO:
  - Show all for entire page
  - Fix clicking on text elements
  - Show box on mouseover
  - Make refs declaration clearer
  - Orient user to what each comparandum is
  """

  def mount(socket) do
    {:ok,
     socket
     |> assign(
       changeset: to_form(TextNode.search_changeset(), as: :search),
       focused_index: 0,
       previewed_text_node_id: nil
     )}
  end

  def update(assigns, socket) do
    if assigns.text_node && assigns.text_node != Map.get(socket.assigns, :text_node) do
      {:ok,
       socket
       |> assign(assigns)
       |> assign(search_results: TextNodes.list_text_node_critica(assigns.text_node))}
    else
      {:ok, socket |> assign(assigns)}
    end
  end

  attr :changeset, :any
  attr :id, :any, required: true
  attr :is_open, :boolean, default: false
  attr :search_results, :list, default: []
  attr :text_node, TextServer.TextNodes.TextNode
  attr :urn, :string, required: true

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
            phx-click-away="command-palette-click-away"
            phx-target={@myself}
            phx-key="escape"
            phx-window-keydown="command-palette-click-away"
          >
            <div class="relative">
              <Icons.search_icon />
              <.form for={@changeset} phx-change="search" phx-target={@myself}>
                <CoreComponents.basic_input
                  type="text"
                  field={@changeset[:search_string]}
                  class="h-12 w-full border-0 bg-transparent pl-11 pr-4 base-content placeholder:base-content focus:ring-0 sm:text-sm"
                  placeholder="Search for comparanda in other versions"
                  role="combobox"
                  aria-expanded="false"
                  aria-controls="options"
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
                <ul class="-mx-2 text-sm base-content" id="text-node-command-palette_search-results" role="listbox">
                  <.list_item
                    :for={text_node <- @search_results}
                    active={@previewed_text_node_id == Integer.to_string(text_node.id)}
                    text_node={text_node}
                  />
                </ul>
              </div>
              <.preview text_node={
                Enum.find(@search_results, List.first(@search_results), fn tn ->
                  Integer.to_string(tn.id) == @previewed_text_node_id
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
  attr :text_node, :map, required: true

  def list_item(assigns) do
    ~H"""
    <!-- Active: "bg-primary base-content" -->
    <li
      class="group flex cursor-pointer select-none items-center rounded-md p-2 hover:bg-stone-200"
      id={"text_node_preview-#{@text_node.id}"}
      role="option"
      tabindex="-1"
      phx-click="preview_text_node"
      phx-value-text_node_id={@text_node.id}
      phx-target="#text-node-command-palette_search-results"
    >
      <section class="truncate">
        <h1 class="font-bold"><%= @text_node.version.label %></h1>
        <span class="base-content"><%= @text_node.version.description %></span>
        <p class="flex-auto truncate"><%= @text_node.text %></p>
      </section>
      <!-- Not Active: "hidden" -->
      <Icons.right_chevron :if={@active} />
    </li>
    """
  end

  attr :text_node, :map, required: true

  def preview(assigns) do
    ~H"""
    <!-- Active item side-panel, show/hide based on active state -->
    <div class="hidden h-96 w-1/2 flex-none flex-col divide-y divide-primary overflow-y-auto sm:flex">
      <div class="flex-none p-6 text-center">
        <h2 class="mt-3 font-semibold base-content"><%= @text_node.version.label %></h2>
        <h3 class="text-sm leading-6 base-content">
          <%= @text_node.version.urn %>:<%= @text_node.location |> Enum.join(".") %>
        </h3>
        <p class="text-sm leading-6 base-content"><%= @text_node.version.description %></p>
      </div>
      <div class="flex flex-auto flex-col justify-between p-6">
        <p class="flex-auto"><%= @text_node.text %></p>
        <div class="relative sticky bottom-0 w-full">
          <button
            type="button"
            class={~w(
                mb-4
                mt-6
                w-full
                rounded-md
                bg-stone-600
                px-3
                py-2
                text-sm
                font-semibold
                text-white
                drop-shadow-xl
                shadow-sm
                hover:bg-stone-500
                focus-visible:outline
                focus-visible:outline-2
                focus-visible:outline-offset-2
                focus-visible:outline-stone-600
              )}
            phx-click="select-sibling-node"
            phx-target="#reading-environment-reader"
            phx-value-text_node_id={@text_node.id}
          >
            Select
          </button>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("command-palette-click-away", _, socket) do
    send(self(), {:focused_text_node, nil})
    {:noreply, socket}
  end

  def handle_event("preview_text_node", %{"text_node_id" => id}, socket) do
    {:noreply, socket |> assign(previewed_text_node_id: id)}
  end

  def handle_event("search", %{"search" => search_params}, socket) do
    changeset =
      TextNode.search_changeset(search_params)
      |> to_form(as: :search)

    {:noreply, socket |> assign(changeset: changeset)}
  end
end
