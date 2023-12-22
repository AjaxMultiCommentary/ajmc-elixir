defmodule TextServerWeb.VersionLive.Show do
  use TextServerWeb, :live_view

  alias TextServerWeb.ReadingEnvironment.Navigation

  alias TextServer.Comments
  alias TextServer.Comments.Comment
  alias TextServer.Commentaries
  alias TextServer.Commentaries.CanonicalCommentary
  alias TextServer.LemmalessComments
  alias TextServer.LemmalessComments.LemmalessComment
  alias TextServer.MultiSelect
  alias TextServer.MultiSelect.SelectOption
  alias TextServer.TextNodes
  alias TextServer.Versions
  alias TextServer.Versions.Passages

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign_new(:current_user, fn -> nil end)
     |> assign(
       focused_text_node: nil,
       version_command_palette_open: false
     )}
  end

  attr :commentaries, :list
  attr :commentary_filter_changeset, Ecto.Changeset
  attr :comments, :list
  attr :focused_text_node, TextNodes.TextNode
  attr :footnotes, :list, default: []
  attr :highlighted_comments, :list
  attr :highlighted_lemmaless_comments, :list, default: []
  attr :lemmaless_comments, :list, default: []
  attr :location, :list, default: []
  attr :passage, Versions.Passage
  attr :passages, :list, default: []
  attr :personae_loquentes, :map, default: %{}
  attr :text_nodes, :list, default: []
  attr :version, Versions.Version, required: true
  attr :versions, :list, required: true

  @impl true
  def render(assigns) do
    ~H"""
    <article class="mx-auto">
      <div class="grid grid-cols-10 gap-x-8 gap-y-2 h-screen max-h-[64rem]">
        <div class="col-span-2">
          <h1 class="text-2xl font-bold"><%= raw(@version.label) %></h1>

          <p><%= @version.description %></p>
        </div>
        <div class="col-span-5">
          <select class="w-full border">
            <option>Critical text</option>
            <option>Lloyd-Jones 1994</option>
            <option>Jebb</option>
            <option>etc.</option>
          </select>
        </div>
        <div class="col-span-3 border max-h-full overflow-y-scroll">
          <.form :let={f} for={@commentary_filter_changeset} id="commentaries-filter-form" phx-change="validate">
            <.live_component
              id="commentaries-filter"
              module={TextServerWeb.Components.MultiSelect}
              options={@commentaries}
              form={f}
              selected={fn opts -> send(self(), {:updated_options, opts}) end}
            />
          </.form>
        </div>

        <hr class="my-4 col-span-10" />

        <div class="col-span-2">
          <Navigation.nav_menu passages={@passages} current_passage={@passage} />
        </div>
        <div class="col-span-5 overflow-y-scroll">
          <.live_component
            id={:reader}
            module={TextServerWeb.ReadingEnvironment.Reader}
            focused_text_node={@focused_text_node}
            footnotes={@footnotes}
            highlighted_comments={@highlighted_comments}
            lemmaless_comments={@lemmaless_comments}
            location={@location}
            passage={@passage}
            personae_loquentes={@personae_loquentes}
            text_nodes={@text_nodes}
            version_urn={@version.urn}
          />
        </div>
        <div class="col-span-3 overflow-y-scroll">
          <%= for comment <- @all_comments do %>
            <.live_component
              id={comment.id}
              module={TextServerWeb.ReadingEnvironment.CollapsibleComment}
              comment={comment}
              is_highlighted={is_highlighted(comment, @highlighted_comments, @highlighted_lemmaless_comments)}
            />
          <% end %>
        </div>
        <div class="col-span-10 flex shadow-xl p-4 bg-base-200">
          Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et
          dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip
          ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore
          eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt
          in culpa qui officia deserunt mollit anim id est laborum.
        </div>
      </div>
    </article>
    """
  end

  @impl true
  def handle_params(%{"urn" => urn, "page" => passage_number} = params, _, socket) do
    version = Versions.get_version_by_urn!(urn)
    passage = Versions.get_version_passage(version.id, passage_number)
    text_nodes = passage.text_nodes

    commentaries =
      Commentaries.list_viewable_commentaries(socket.assigns.current_user)
      |> Enum.map(fn c ->
        %{id: c.id, label: CanonicalCommentary.commentary_label(c), selected: false}
      end)
      |> build_options()

    personae_loquentes = get_personae_loquentes(text_nodes)

    socket =
      socket
      |> assign(
        form: to_form(params),
        highlighted_comments: [],
        passage: passage,
        passages: Passages.list_passages_for_version(version),
        page_title: version.label,
        personae_loquentes: personae_loquentes,
        text_nodes: text_nodes,
        version: version
      )
      |> assign_multi_select_options(commentaries)

    {:noreply, socket}
  end

  def handle_params(params, session, socket) do
    handle_params(
      params |> Enum.into(%{"page" => "1"}),
      session,
      socket
    )
  end

  @impl true
  def handle_event("highlight-comments", %{"comments" => comment_ids}, socket) do
    ids =
      comment_ids
      |> Jason.decode!()

    send(self(), {:comments_highlighted, ids})
    {:noreply, socket |> assign(highlighted_comments: ids)}
  end

  def handle_event("highlight-lemmaless-comments", %{"comments" => comment_ids}, socket) do
    ids =
      comment_ids
      |> Jason.decode!()

    {:noreply, socket |> assign(highlighted_lemmaless_comments: ids)}
  end

  def handle_event("validate", %{"multi_select" => multi_component}, socket) do
    options = build_options(multi_component["options"])

    {:noreply, assign_multi_select_options(socket, options)}
  end

  def handle_event(event, params, socket) do
    IO.puts("Failed to capture event #{event}")
    IO.inspect(params)

    {:noreply, socket}
  end

  @impl true
  def handle_info({:comments_highlighted, [id | _]}, socket) do
    {:noreply, push_event(socket, "highlight-comment", %{id: "comment-#{id}"})}
  end

  def handle_info({:updated_options, options}, socket) do
    # update the list of comments, the selected commentaries and the changeset in the form
    {:noreply, assign_multi_select_options(socket, options)}
  end

  defp assign_multi_select_options(socket, commentaries) do
    selected_options =
      Enum.flat_map(commentaries, fn option ->
        if option.selected in [true, "true"] do
          [option.id]
        else
          []
        end
      end)

    text_nodes = socket.assigns.text_nodes
    comments = filter_comments(socket, text_nodes, selected_options)
    lemmaless_comments = filter_lemmaless_comments(socket, text_nodes, selected_options)
    text_nodes = TextNodes.tag_text_nodes(socket.assigns.text_nodes, comments)

    all_comments =
      (comments ++ lemmaless_comments)
      |> Enum.sort_by(fn
        %Comment{} = comment ->
          comment.start_text_node.location

        %LemmalessComment{} = comment ->
          comment.urn.citations |> List.first() |> String.to_integer()
      end)

    socket
    |> assign(
      all_comments: all_comments,
      commentaries: commentaries,
      commentary_filter_changeset: build_changeset(commentaries),
      lemmaless_comments: lemmaless_comments,
      text_nodes: text_nodes
    )
  end

  defp build_options(options) do
    Enum.map(options, fn
      {_idx, data} ->
        %SelectOption{id: data["id"], label: data["label"], selected: data["selected"]}

      data ->
        %SelectOption{id: data.id, label: data.label, selected: data.selected}
    end)
    |> Enum.sort_by(&Map.get(&1, :label))
  end

  defp build_changeset(options) do
    %MultiSelect{}
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_embed(:options, options)
  end

  defp filter_comments(socket, text_nodes, selected_options) do
    Comments.filter_comments(
      socket.assigns.current_user,
      selected_options,
      text_nodes |> Enum.map(& &1.id)
    )
    |> Enum.sort_by(&{&1.start_text_node.location, &1.start_offset})
  end

  defp filter_lemmaless_comments(_socket, text_nodes, _) when length(text_nodes) == 0 do
    []
  end

  defp filter_lemmaless_comments(socket, text_nodes, selected_options) do
    first_line_n = text_nodes |> List.first() |> Map.get(:location) |> List.first()
    last_line_n = text_nodes |> List.last() |> Map.get(:location) |> List.first()

    LemmalessComments.filter_lemmaless_comments(
      socket.assigns.current_user,
      selected_options,
      first_line_n,
      last_line_n
    )
    |> Enum.sort_by(&(&1.urn.citations |> List.first()))
  end

  defp get_personae_loquentes(text_nodes) do
    text_nodes
    |> Enum.chunk_by(fn tn ->
      tn.text_elements
      |> Enum.find(fn te -> te.element_type.name == "speaker" end)
      |> Map.get(:attributes)
      |> Map.get("name")
    end)
    |> Enum.reduce(%{}, fn chunk, acc ->
      [node | _rest] = chunk

      speaker_name =
        node.text_elements
        |> Enum.find(fn te -> te.element_type.name == "speaker" end)
        |> Map.get(:attributes)
        |> Map.get("name")

      Map.put(acc, node.offset, speaker_name)
    end)
  end

  defp is_highlighted(%Comment{} = comment, comment_ids, _) do
    Enum.member?(comment_ids, comment.id)
  end

  defp is_highlighted(%LemmalessComment{} = comment, _, lemmaless_comment_ids) do
    Enum.member?(lemmaless_comment_ids, comment.id)
  end
end
