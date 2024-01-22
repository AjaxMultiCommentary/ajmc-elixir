defmodule TextServerWeb.VersionLive.Show do
  use TextServerWeb, :live_view

  alias TextServerWeb.ReadingEnvironment.Navigation
  alias TextServerWeb.Icons

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
  alias TextServer.Versions.Version

  @impl true
  def mount(%{"urn" => urn} = _params, _session, socket) do
    {:ok,
     socket
     |> assign_new(:current_user, fn -> nil end)
     |> assign(
       urn: urn,
       focused_text_node: nil,
       multi_select_filter_value: ""
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
  attr :multi_select_filter_value, :string, default: ""
  attr :passage, Versions.Passage
  attr :passages, :list, default: []
  attr :personae_loquentes, :map, default: %{}
  attr :text_nodes, :list, default: []
  attr :version, Versions.Version, required: true
  attr :versions_for_select, :list, required: true

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
          <.form :let={f} for={to_form(Versions.change_version(%Version{}))} id="version-select" phx-change="change-version">
            <.input field={f[:id]} type="select" options={@versions_for_select} value={CTS.URN.to_string(@version.urn)} />
          </.form>
        </div>
        <div class="dropdown">
          <div tabindex="0" role="button" class="btn m-1"><Icons.filter /></div>
          <div tabindex="0" class="p-4 shadow dropdown-content z-[1] bg-base-100 max-h-64 w-fit overflow-y-scroll">
            <.form :let={f} for={@commentary_filter_changeset} id="commentaries-filter-form" phx-change="validate">
              <input type="text" name="multi-select-filter" value={@multi_select_filter_value} phx-change="filter-change" />
              <.live_component
                id="commentaries-filter"
                module={TextServerWeb.Components.MultiSelect}
                options={@commentaries}
                form={f}
                selected={fn opts -> send(self(), {:updated_options, opts}) end}
              />
            </.form>
          </div>
        </div>

        <hr class="my-4 col-span-10" />

        <div class="col-span-2">
          <Navigation.nav_menu passages={@passages} current_passage={@passage} />
        </div>
        <div class="col-span-5 overflow-y-scroll -mt-4">
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
              id={"#{comment.__struct__}-#{comment.id}"}
              module={TextServerWeb.ReadingEnvironment.CollapsibleComment}
              comment={comment}
              current_user={@current_user}
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

    commentaries = list_commentaries(socket, text_nodes)

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
        version: version,
        versions_for_select:
          list_versions()
          |> Enum.map(fn v ->
            {raw("#{v.label} #{v.description}"), CTS.URN.to_string(v.urn)}
          end)
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
  def handle_event("change-version", %{"version" => %{"id" => urn}}, socket) do
    {:noreply,
     push_navigate(socket, to: ~p"/versions/#{urn}?page=#{socket.assigns.passage.passage_number}")}
  end

  def handle_event("filter-change", %{"multi-select-filter" => filter_s}, socket) do
    send(
      self(),
      {:updated_options,
       list_commentaries(socket, socket.assigns.text_nodes)
       |> Enum.filter(&String.starts_with?(String.downcase(&1.label), filter_s))}
    )

    {:noreply, socket |> assign(:multi_select_filter_value, filter_s)}
  end

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

    send(self(), {:comments_highlighted, ids})
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
    {:noreply, push_event(socket, "highlight-comment", %{id: "#{id}"})}
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
      |> Enum.sort_by(fn comment ->
        {comment.urn.citations |> List.first() |> String.to_integer(),
         Map.get(comment, :start_offset, 0)}
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
        %SelectOption{
          id: data["id"],
          count: data["count"],
          label: data["label"],
          selected: data["selected"]
        }

      data ->
        %SelectOption{id: data.id, count: data.count, label: data.label, selected: data.selected}
    end)
    |> Enum.sort_by(&Map.get(&1, :label))
  end

  defp build_changeset(options) do
    %MultiSelect{}
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_embed(:options, options)
  end

  defp filter_comments(socket, text_nodes, selected_options) do
    first_line_n = List.first(text_nodes).location |> Enum.at(0) |> String.to_integer()
    last_line_n = List.last(text_nodes).location |> Enum.at(0) |> String.to_integer()

    Comments.filter_comments(
      socket.assigns.current_user,
      selected_options,
      first_line_n,
      last_line_n
    )
  end

  defp filter_lemmaless_comments(_socket, text_nodes, _) when length(text_nodes) == 0 do
    []
  end

  defp filter_lemmaless_comments(socket, text_nodes, selected_options) do
    first_line_n =
      text_nodes |> List.first() |> Map.get(:location) |> List.first() |> String.to_integer()

    last_line_n =
      text_nodes |> List.last() |> Map.get(:location) |> List.first() |> String.to_integer()

    LemmalessComments.filter_lemmaless_comments(
      socket.assigns.current_user,
      selected_options,
      first_line_n,
      last_line_n
    )
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
    Enum.member?(comment_ids, "#{comment.__struct__}-#{comment.id}")
  end

  defp is_highlighted(%LemmalessComment{} = comment, _, lemmaless_comment_ids) do
    Enum.member?(lemmaless_comment_ids, "#{comment.__struct__}-#{comment.id}")
  end

  defp list_commentaries(socket, text_nodes) do
    comments = filter_comments(socket, text_nodes, [])
    lemmaless_comments = filter_lemmaless_comments(socket, text_nodes, [])
    all_comments = comments ++ lemmaless_comments

    commentary_frequencies =
      all_comments |> Enum.frequencies_by(&Map.get(&1, :canonical_commentary_id))

    Commentaries.list_viewable_commentaries(socket.assigns.current_user)
    |> Enum.map(fn c ->
      %{
        id: c.id,
        count: commentary_frequencies[c.id] || 0,
        label: CanonicalCommentary.commentary_label(c),
        selected: false
      }
    end)
    |> build_options()
  end

  defp list_versions do
    Versions.list_versions()
  end
end
