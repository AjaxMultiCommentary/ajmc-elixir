defmodule TextServerWeb.VersionLive.Show do
  use TextServerWeb, :live_view

  require Logger

  alias TextServerWeb.ReadingEnvironment.Navigation
  alias TextServerWeb.Components.Tooltip

  alias TextServer.Comments
  alias TextServer.Commentaries
  alias TextServer.Commentaries.CanonicalCommentary
  alias TextServer.LemmalessComments
  alias TextServer.MultiSelect
  alias TextServer.MultiSelect.SelectOption
  alias TextServer.TextNodes
  alias TextServer.Versions
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
  attr :current_urn, CTS.URN, default: %CTS.URN{}
  attr :focused_text_node, TextNodes.TextNode
  attr :footnotes, :list, default: []
  attr :highlighted_comments, :list, default: []
  attr :highlighted_lemmaless_comments, :list, default: []
  attr :lemmaless_comments, :list, default: []
  attr :location, :list, default: []
  attr :multi_select_filter_value, :string, default: ""
  attr :personae_loquentes, :map, default: %{}
  attr :text_nodes, :list, default: []
  attr :version, Versions.Version, required: true
  attr :versions_for_select, :list, required: true

  @impl true
  def render(assigns) do
    ~H"""
    <article class="mx-auto">
      <div class="grid grid-cols-10 gap-x-8 gap-y-2 h-screen max-h-[64rem]">
        <div class="col-span-full">
          <h1 class="text-2xl font-bold"><em>Ajax</em> Multi-Commentary</h1>

          <p><%= gettext("about_the_multi_commentary") %></p>
        </div>

        <hr class="my-4 col-span-10" />

        <div class="col-span-2">
          <section class="mb-8">
            <div class="flex justify-between items-center mb-2">
              <h3 class="text-sm font-bold prose prose-h3">
                <%= gettext("Change critical text") %>
              </h3>
              <Tooltip.info icon_class="h-5 w-5" tip={gettext("
                    You can change the edition used for the critical text here.
                    Keep in mind that the lemmata of the glosses are based on the Lloyd-Jones
                    version of the text, so they might not match up if you prefer to use another edition.
                      ")} />
            </div>
            <.form
              :let={f}
              for={to_form(Versions.change_version(%Version{}))}
              id="version-select"
              phx-change="change-version"
            >
              <.input field={f[:id]} type="select" options={@versions_for_select} value={CTS.URN.to_string(@version.urn)} />
            </.form>
          </section>
          <section class="mb-8">
            <div class="flex justify-between items-center mb-2">
              <h3 class="text-sm font-bold prose prose-h3"><%= gettext("Navigation") %></h3>
              <Tooltip.info
                icon_class="h-5 w-5"
                tip={gettext("This synopsis is based on the Lloyd-Jones edition of the text,
                    and the line numbers might not line up exactly with other editions.
                    Click on a section of the synopsis to view it in the critical text area.
                    ")}
              />
            </div>
            <Navigation.nav_menu current_urn={@current_urn} version={@version} />
          </section>
          <section>
            <div class="flex justify-between items-center mb-2">
              <h3 class="text-sm font-bold prose prose-h3"><%= gettext("Filter glosses") %></h3>
              <Tooltip.info
                icon_class="h-5 w-5"
                tip={
                  gettext(
                    "Use this filter to show or hide comments on the right. You can search for a commentary by name using the text box."
                  )
                }
              />
            </div>
            <.form :let={f} for={@commentary_filter_changeset} id="commentaries-filter-form" phx-change="validate">
              <input type="text" name="multi-select-filter" value={@multi_select_filter_value} class={~w(
                  w-full input input-secondary input-sm mb-2
                )} phx-change="filter-change" placeholder="Filter commentaries" />
              <div class="max-h-48 overflow-y-scroll">
                <.live_component
                  id="commentaries-filter"
                  module={TextServerWeb.Components.MultiSelect}
                  options={@commentaries}
                  form={f}
                  selected={fn opts -> send(self(), {:updated_options, opts}) end}
                />
              </div>
            </.form>
          </section>
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
            personae_loquentes={@personae_loquentes}
            text_nodes={@text_nodes}
            version_urn={@version.urn}
          />
        </div>
        <div class="col-span-3 overflow-y-scroll">
          <%= for comment <- @all_comments do %>
            <.live_component
              id={comment.interface_id}
              module={TextServerWeb.ReadingEnvironment.CollapsibleComment}
              comment={comment}
              current_user={@current_user}
              highlighted?={highlighted?(comment, @highlighted_comments)}
              passage_urn={@current_urn}
            />
          <% end %>
        </div>
        <section class="col-span-10 shadow-xl p-4 bg-base-200 hidden">
          <div class="flex items-center mb-2">
            <h3 class="prose prose-h3 text-sm font-bold mr-1"><%= gettext("Dynamic apparatus") %></h3>
            <Tooltip.info
              icon_class="h-5 w-5"
              tip={
                gettext(
                  "The dynamic apparatus shows the difference between the current critical text and other available critical texts."
                )
              }
            />
          </div>
          <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et
            dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip
            ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore
            eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt
            in culpa qui officia deserunt mollit anim id est laborum.</p>
        </section>
      </div>
    </article>
    """
  end

  @impl true
  def handle_params(%{"urn" => urn} = params, _, socket) do
    urn = CTS.URN.parse(urn)
    version = Versions.get_version_by_urn!(urn)

    [start_location, end_location] =
      if is_nil(urn.passage_component) do
        [["1"], ["133"]]
      else
        urn.passage_component |> String.split("-") |> Enum.map(&[&1])
      end

    text_nodes =
      TextNodes.list_text_nodes_by_version_between_locations(
        version,
        start_location,
        end_location
      )

    personae_loquentes = get_personae_loquentes(text_nodes)

    socket =
      socket
      |> assign(
        current_urn: urn,
        form: to_form(params),
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

    commentaries = list_commentaries(socket)

    gloss = Map.get(params, "gloss")

    socket =
      socket
      |> assign(commentaries: commentaries)
      |> assign_multi_select_options(commentaries)
      |> maybe_highlight_gloss(gloss)

    maybe_scroll_line_into_view(gloss)

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
    urn = "#{urn}:#{socket.assigns.current_urn.passage_component}"
    {:noreply, push_navigate(socket, to: ~p"/versions/#{urn}")}
  end

  def handle_event("filter-change", %{"multi-select-filter" => filter_s}, socket) do
    send(
      self(),
      {:updated_options,
       list_commentaries(socket)
       |> Enum.filter(&String.starts_with?(String.downcase(&1.label), String.downcase(filter_s)))}
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

  def handle_event("validate", %{"multi_select" => multi_component}, socket) do
    options = build_options(multi_component["options"])

    {:noreply, assign_multi_select_options(socket, options)}
  end

  def handle_event(event, params, socket) do
    Logger.error("Failed to capture event #{event} with params \n #{inspect(params)}")

    {:noreply, socket}
  end

  @impl true
  def handle_info({:comments_highlighted, [id | _]}, socket) do
    {:noreply, push_event(socket, "scroll-into-view", %{id: id})}
  end

  def handle_info({:focus_line, interface_id}, socket) do
    {:noreply, push_event(socket, "scroll-into-view", %{id: interface_id})}
  end

  def handle_info({:unhighlight_comment, comment_interface_id}, socket) do
    {:noreply,
     socket
     |> assign(
       highlighted_comments:
         socket.assigns.highlighted_comments
         |> Enum.reject(fn c -> c == comment_interface_id end)
     )}
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

    comments =
      filter_comments(socket, text_nodes, selected_options)
      |> Enum.map(&Comments.with_interface_id/1)

    lemmaless_comments =
      filter_lemmaless_comments(socket, text_nodes, selected_options)
      |> Enum.map(&LemmalessComments.with_interface_id/1)

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

  defp highlighted?(comment, highlighted_comment_ids) do
    Enum.member?(highlighted_comment_ids, comment.interface_id)
  end

  defp list_commentaries(socket) do
    text_nodes = socket.assigns.text_nodes
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
        selected:
          Enum.find_value(Map.get(socket.assigns, :commentaries, []), fn assigned_c ->
            if assigned_c.id == c.id do
              assigned_c.selected
            end
          end)
      }
    end)
    |> build_options()
  end

  defp list_versions do
    Versions.list_versions()
  end

  defp maybe_highlight_gloss(socket, nil), do: socket

  defp maybe_highlight_gloss(socket, gloss) do
    gloss_urn = CTS.URN.parse("urn:cts:greekLit:#{gloss}")

    case gloss_urn do
      %CTS.URN{subsections: [nil, nil]} ->
        comment =
          LemmalessComments.get_lemmaless_comment_by_urn!(gloss_urn)
          |> LemmalessComments.with_interface_id()

        highlights = [comment.interface_id]
        send(self(), {:comments_highlighted, highlights})
        assign(socket, :highlighted_lemmaless_comments, highlights)

      %CTS.URN{subsections: [lemma, _]} ->
        comment =
          Comments.get_comment_by_urn_with_lemma!(gloss_urn, lemma)
          |> Comments.with_interface_id()

        highlights = [comment.interface_id]
        send(self(), {:comments_highlighted, highlights})
        assign(socket, :highlighted_comments, highlights)
    end
  end

  defp maybe_scroll_line_into_view(nil), do: nil

  defp maybe_scroll_line_into_view(gloss) do
    gloss_urn = CTS.URN.parse("urn:cts:greekLit:#{gloss}")
    line_n = gloss_urn.citations |> List.first()

    send(self(), {:focus_line, "line-#{line_n}"})

    :ok
  end
end
