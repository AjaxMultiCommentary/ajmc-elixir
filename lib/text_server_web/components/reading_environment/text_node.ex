defmodule TextServerWeb.ReadingEnvironment.TextNode do
  use TextServerWeb, :live_component

  alias TextServer.TextNodes

  attr :highlighted_comments, :list, default: []
  attr :lemmaless_comments, :list, default: []
  attr :persona_loquens, :string
  attr :text_node, :map, required: true

  @impl true
  def render(assigns) do
    # NOTE: (charles) It's important, unfortunately, for the `for` statement
    # to be on one line so that we don't get extra spaces around elements.
    ~H"""
    <div id={TextNodes.with_interface_id(@text_node).interface_id}>
      <h3 :if={@persona_loquens} class="font-bold pt-4"><%= @persona_loquens %></h3>
      <div class="flex justify-between">
        <p class="max-w-prose text-node" phx-target={@myself}>
          <.text_element
            :for={{graphemes, tags} <- @text_node.graphemes_with_tags}
            highlighted_comments={@highlighted_comments}
            tags={tags}
            text={Enum.join(graphemes)}
          />
        </p>
        <.line_number lemmaless_comments={@lemmaless_comments} location={@text_node.location} />
      </div>
    </div>
    """
  end

  attr :lemmaless_comments, :list, default: []
  attr :location, :string

  def line_number(assigns) do
    ~H"""
    <span
      class={[
        "base-content hover:base-content cursor-pointer @@ajmc-comment-box-shadow w-12 text-center inline-block",
        "comments-#{min(Enum.count(@lemmaless_comments), 10)}"
      ]}
      phx-click="highlight-comments"
      phx-value-comments={@lemmaless_comments |> Enum.map(& &1.interface_id) |> Jason.encode!()}
    >
      <%= Enum.join(@location, ".") %>
    </span>
    """
  end

  attr :classes, :string, default: ""
  attr :highlighted_comments, :list, default: []
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
              |> Enum.map(& &1.metadata.interface_id),
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
            classes: [
              assigns.classes,
              "comments-#{min(Enum.count(assigns.commentary_ids), 10)}",
              highlighted?(assigns.comments, assigns.highlighted_comments)
            ]
          )

        ~H"""
        <span
          class={@classes}
          title={"#{Enum.count(assigns.commentary_ids)} glosses on this lemma"}
          phx-click="highlight-comments"
          phx-value-comments={@comments |> Jason.encode!()}
        >
          <%= @text %>
        </span>
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

  defp highlighted?(comment_ids, highlighted_comment_ids) do
    if Enum.any?(comment_ids, fn id ->
         Enum.member?(highlighted_comment_ids, id)
       end) do
      "border border-md"
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
