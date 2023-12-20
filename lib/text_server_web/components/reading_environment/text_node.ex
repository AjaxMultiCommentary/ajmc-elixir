defmodule TextServerWeb.ReadingEnvironment.TextNode do
  use TextServerWeb, :live_component

  attr :comments, :list, default: []
  attr :is_focused, :boolean, default: false
  attr :persona_loquens, :string
  attr :text_node, :map, required: true

  @impl true
  def mount(socket) do
    {:ok, socket |> assign(is_focused: false)}
  end

  @impl true
  def render(assigns) do
    # NOTE: (charles) It's important, unfortunately, for the `for` statement
    # to be on one line so that we don't get extra spaces around elements.
    ~H"""
    <div>
      <h3 :if={@persona_loquens} class="font-bold mt-4 first:mt-0"><%= @persona_loquens %></h3>
      <div class="flex justify-between">
        <p class="max-w-prose text-node" phx-click="text-node-click" phx-target={@myself}>
          <.text_element :for={{graphemes, tags} <- @text_node.graphemes_with_tags} tags={tags} text={Enum.join(graphemes)} />
        </p>
        <span class="text-slate-300 hover:text-slate-500 mr-8"><%= Enum.join(@text_node.location, ".") %></span>
      </div>
    </div>
    """
  end

  attr :classes, :string, default: ""
  attr :tags, :list, default: []
  attr :text, :string

  def text_element(assigns) do
    tags = assigns[:tags]

    assigns =
      assign(
        assigns,
        :classes,
        tags
        |> Enum.map(&tag_classes/1)
        |> MapSet.new()
        |> Enum.join(" ")
      )

    cond do
      Enum.member?(tags |> Enum.map(& &1.name), "comment") ->
        assigns =
          assign(
            assigns,
            comments:
              tags
              |> Enum.filter(&(&1.name == "comment"))
              |> Enum.map(& &1.metadata.id)
              |> Jason.encode!(),
            commentary_ids:
              tags
              |> Enum.filter(&(&1.name == "comment"))
              |> Enum.map(& &1.metadata.canonical_commentary.pid)
              |> Enum.dedup()
          )

        # We need to do this to keep the autoformatter from making the <span> span
        # multiple lines, introducing unnecessary whitespace into the text
        assigns =
          assign(
            assigns,
            classes: [assigns.classes, "comments-#{min(Enum.count(assigns.commentary_ids), 10)}"]
          )

        ~H"""
        <span class={@classes} phx-click="highlight-comments" phx-value-comments={@comments}><%= @text %></span>
        """

      Enum.member?(tags |> Enum.map(& &1.name), "image") ->
        assigns =
          assign(
            assigns,
            src:
              tags |> Enum.find(&(&1.name == "image")) |> Map.get(:metadata, %{}) |> Map.get(:src)
          )

        ~H"<img class={@classes} src={@src} />"

      Enum.member?(tags |> Enum.map(& &1.name), "link") ->
        assigns =
          assign(
            assigns,
            :src,
            tags |> Enum.find(&(&1.name == "link")) |> Map.get(:metadata, %{}) |> Map.get(:src)
          )

        ~H"""
        <a class={@classes} href={@src}><%= @text %></a>
        """

      Enum.member?(tags |> Enum.map(& &1.name), "note") ->
        assigns =
          assign(
            assigns,
            :footnote,
            tags |> Enum.find(&(&1.name == "note")) |> Map.get(:metadata, %{})
          )

        ~H"""
        <span class={@classes}>
          <%= @text %><a href={"#_fn-#{@footnote[:id]}"} id={"_fn-ref-#{@footnote[:id]}"}><sup>*</sup></a>
        </span>
        """

      true ->
        ~H"<span class={@classes}><%= @text %></span>"
    end
  end

  defp tag_classes(tag) do
    case tag.name do
      "add" -> "@@ajmc-addition"
      "comment" -> "@@ajmc-comment-box-shadow cursor-pointer"
      "del" -> "line-through"
      "emph" -> "italic"
      "image" -> "image mt-10"
      "link" -> "link font-bold underline hover:opacity-75 visited:opacity-60"
      "strong" -> "font-bold"
      "underline" -> "underline"
      _ -> tag.name
    end
  end
end
