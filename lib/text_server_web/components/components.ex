defmodule TextServerWeb.Components do
  use TextServerWeb, :component

  attr :item, :map, required: true
  attr :url, :string, required: true

  slot :inner_block

  def card(assigns) do
    ~H"""
    <div class="group relative">
      <div class="w-full min-h-80 bg-gray-200 aspect-w-1 aspect-h-1 rounded-md overflow-hidden group-hover:opacity-75 lg:h-80 lg:aspect-none">
        <p class="align-text-center flex items-center justify-center w-full h-full text-9xl">
          <%= render_slot(@inner_block) %>
        </p>
      </div>
      <div class="mt-4 flex justify-between">
        <div>
          <h3 class="font-bold text-gray-700">
            <a href={@url}>
              <span aria-hidden="true" class="absolute inset-0"></span> <%= Map.get(@item, :title) %>
            </a>
          </h3>
          <p class="mt-1 text-sm text-gray-500"><%= @item.description %></p>
        </div>
      </div>
    </div>
    """
  end

  attr :comments, :list, default: []
  attr :highlighted_comments, :list, default: []

  def floating_comments(assigns) do
    ~H"""
    <div>
      <details
        :for={c <- @comments}
        class={[
          "border-2 collapse collapse-arrow rounded-md mb-2",
          if(Enum.member?(@highlighted_comments, Map.get(c, :id, nil)), do: "border-stone-800", else: "")
        ]}
      >
        <input type="checkbox" class="min-h-0" />
        <summary class="collapse-title">
          <h3 class="text-md font-medium leading-6 text-gray-900">
            <%= c.attributes |> Map.get("lemma") %>
          </h3>
          <small class="mt-1 mx-w-2xl text-sm text-gray-500"><%= c.author %></small>
        </summary>
        <div class="collapse-content float-right">
          <p class="mt-1 max-w-2xl text-sm text-gray-800"><%= c.content %></p>
        </div>
      </details>
    </div>
    """
  end

  attr :footnotes, :list, default: []

  def footnotes(assigns) do
    ~H"""
    <%= for {footnote, i} <- Enum.with_index(@footnotes) do %>
      <p class="text-stone-500">
        <a href={"#_fn-ref-#{footnote.id}"} id={"_fn-#{footnote.id}"}><sup><%= i + 1 %></sup></a>
        <span><%= footnote.content %></span>
      </p>
    <% end %>
    """
  end

  slot :inner_block, required: true
  attr :items, Scrivener.Page, default: %Scrivener.Page{}

  def search_list(assigns) do
    ~H"""
    <ul role="list" class="divide-y divide-gray-200 sm:max-w-lg">
      <%= for item <- @items do %>
        <%= render_slot(@inner_block, item) %>
      <% end %>
    </ul>
    """
  end

  attr :description, :string, default: ""
  attr :title, :string, required: true
  attr :url, :string, default: "#"

  def search_list_item(assigns) do
    ~H"""
    <li class="px-4 py-4 sm:px-0">
      <.link href={@url} class="flex justify-between items-center hover:opacity-60">
        <div>
          <h3 class="font-bold lg:prose-lg">
            <%= @title %>
          </h3>
          <p class="lg:prose-lg"><%= @description %></p>
        </div>
        <span>❯</span>
      </.link>
    </li>
    """
  end

  attr :classes, :string, default: ""
  attr :form, :any, required: true
  attr :name, :atom, required: true
  attr :on_change, :string
  attr :options, :list, default: []

  def select_dropdown(assigns) do
    ~H"""
    <%= select(
      @form,
      @name,
      @options,
      class: ~w(
                appearance-none
                relative
                resize-none
                flex-1
                py-2
                mb-4
                border
                border-gray-300
                placeholder-gray-500
                text-gray-900
                focus:outline-none
                focus:ring-stone-500
                focus:border-stone-500
                focus:z-10
                sm:text-sm
                #{@classes}
              ),
      "phx-change": assigns[:on_change]
    ) %>
    """
  end

  attr :description, :string
  attr :title, :string, required: true
  attr :url, :string, default: "#"

  def small_card(assigns) do
    ~H"""
    <a href={@url}>
      <div class="flex py-6 rounded shadow-md hover:shadow-lg">
        <div class="ml-4 flex flex-1 flex-col">
          <div>
            <div class="flex justify-between text-base font-medium text-gray-900">
              <h3><%= @title %></h3>
            </div>
          </div>
          <div class="flex flex-1 justify-between text-sm">
            <p class="text-sm text-gray-500"><%= @description %></p>
          </div>
        </div>
      </div>
    </a>
    """
  end

  attr :current_page, :integer, required: true
  attr :total_pages, :integer, required: true

  def pagination(assigns) do
    ~H"""
    <div class="flex items-center justify-between border-t border-stone-200 bg-white px-4 py-3 sm:px-6">
      <div class="sm:flex sm:justify-between mx-auto">
        <nav class="isolate inline-flex -space-x-px rounded-md shadow-sm" aria-label="Pagination">
          <.first_page_button current_page={@current_page} />
          <.prev_button current_page={@current_page} />
          <!-- Current: "z-10 bg-stone-50 border-stone-500 text-stone-600", Default: "bg-white border-gray-300 text-gray-500 hover:bg-gray-50" -->
          <.numbered_buttons current_page={@current_page} total_pages={@total_pages} />
          <.next_button current_page={@current_page} total_pages={@total_pages} />
          <.last_page_button current_page={@current_page} total_pages={@total_pages} />
        </nav>
      </div>
    </div>
    """
  end

  attr :current_page, :integer, required: true

  defp first_page_button(assigns) do
    ~H"""
    <.link
      patch="?page=1"
      class={[
        "relative",
        "inline-flex",
        "items-center",
        "rounded-l-md",
        "border",
        "bg-white",
        "px-2",
        "py-2",
        "text-sm",
        "font-medium",
        "text-stone-100",
        if(@current_page == 1, do: "cursor-default", else: "hover:bg-gray-50 text-stone-700")
      ]}
    >
      <span class="sr-only">First page</span>
      <!-- Heroicon name: mini/chevron-double-left -->
      <svg
        xmlns="http://www.w3.org/2000/svg"
        fill="none"
        viewBox="0 0 24 24"
        stroke-width="1.5"
        stroke="currentColor"
        class="h-5 w-5"
      >
        <path stroke-linecap="round" stroke-linejoin="round" d="M18.75 19.5l-7.5-7.5 7.5-7.5m-6 15L5.25 12l7.5-7.5" />
      </svg>
    </.link>
    """
  end

  attr :current_page, :integer, required: true
  attr :total_pages, :integer, required: true

  defp last_page_button(assigns) do
    ~H"""
    <.link
      patch={"?page=#{@total_pages}"}
      class={[
        "relative",
        "inline-flex",
        "items-center",
        "rounded-r-md",
        "border",
        "bg-white",
        "px-2",
        "py-2",
        "text-sm",
        "font-medium",
        "text-gray-100",
        if(@current_page == @total_pages, do: "cursor-default", else: "hover:bg-gray-50 text-stone-700")
      ]}
    >
      <span class="sr-only">Last page</span>
      <!-- Heroicon name: mini/chevron-double-right -->
      <svg
        xmlns="http://www.w3.org/2000/svg"
        fill="none"
        viewBox="0 0 24 24"
        stroke-width="1.5"
        stroke="currentColor"
        class="h-5 w-5"
      >
        <path stroke-linecap="round" stroke-linejoin="round" d="M11.25 4.5l7.5 7.5-7.5 7.5m-6-15l7.5 7.5-7.5 7.5" />
      </svg>
    </.link>
    """
  end

  attr :current_page, :integer, required: true
  attr :total_pages, :integer, required: true

  defp next_button(assigns) do
    ~H"""
    <.link
      patch={"?page=#{min(@current_page + 1, @total_pages)}"}
      class={[
        "relative",
        "inline-flex",
        "items-center",
        "border",
        "bg-white",
        "px-2",
        "py-2",
        "text-sm",
        "font-medium",
        "text-gray-100",
        if(@current_page == @total_pages, do: "cursor-default", else: "hover:bg-gray-50 text-stone-700")
      ]}
    >
      <span class="sr-only">Next</span>
      <!-- Heroicon name: mini/chevron-right -->
      <svg class="h-5 w-5" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
        <path
          fill-rule="evenodd"
          d="M7.21 14.77a.75.75 0 01.02-1.06L11.168 10 7.23 6.29a.75.75 0 111.04-1.08l4.5 4.25a.75.75 0 010 1.08l-4.5 4.25a.75.75 0 01-1.06-.02z"
          clip-rule="evenodd"
        />
      </svg>
    </.link>
    """
  end

  attr :current_page, :integer, required: true
  attr :max_buttons, :integer, default: 4
  attr :total_pages, :integer, required: true

  defp numbered_buttons(assigns) do
    ~H"""
    <%= for i <- max(@current_page - 1, 1)..min(@current_page + @max_buttons, @total_pages) do %>
      <.link patch={"?page=#{i}"} aria-current="page" class={numbered_button_classes(@current_page, i)}><%= i %></.link>
    <% end %>
    """
  end

  defp numbered_button_classes(current_page, i) do
    [
      "relative",
      "z-10",
      "inline-flex",
      "items-center",
      "border",
      "px-4",
      "py-2",
      "text-sm",
      "font-medium",
      if(current_page == i,
        do: "bg-stone-100 border-stone-500 text-stone-600 z-20",
        else: "text-gray-500 hover:bg-gray-50"
      )
    ]
  end

  attr :current_page, :integer, required: true

  defp prev_button(assigns) do
    ~H"""
    <.link
      patch={"?page=#{max(@current_page - 1, 1)}"}
      class={[
        "relative",
        "inline-flex",
        "items-center",
        "border",
        "bg-white",
        "px-2",
        "py-2",
        "text-sm",
        "font-medium",
        "text-gray-100",
        if(@current_page == 1, do: "cursor-default", else: "hover:bg-gray-50 text-stone-700")
      ]}
    >
      <span class="sr-only">Previous</span>
      <!-- Heroicon name: mini/chevron-left -->
      <svg class="h-5 w-5" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
        <path
          fill-rule="evenodd"
          d="M12.79 5.23a.75.75 0 01-.02 1.06L8.832 10l3.938 3.71a.75.75 0 11-1.04 1.08l-4.5-4.25a.75.75 0 010-1.08l4.5-4.25a.75.75 0 011.06.02z"
          clip-rule="evenodd"
        />
      </svg>
    </.link>
    """
  end
end
