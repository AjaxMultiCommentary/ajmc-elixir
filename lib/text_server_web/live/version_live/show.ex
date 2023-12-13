defmodule TextServerWeb.VersionLive.Show do
  use TextServerWeb, :live_view

  alias TextServerWeb.ReadingEnvironment.Navigation

  alias TextServer.Comments
  alias TextServer.Commentaries
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
  attr :location, :list, default: []
  attr :passage, Versions.Passage
  attr :passages, :list, default: []
  attr :text_nodes, :list, default: []
  attr :version, Versions.Version, required: true
  attr :versions, :list, required: true

  @impl true
  def render(assigns) do
    ~H"""
    <article class="mx-auto">
      <div class="flex justify-between">
        <div>
          <h1 class="text-2xl font-bold"><%= raw(@version.label) %></h1>

          <p><%= @version.description %></p>

          <p><%= @version.urn %></p>
        </div>
        <div>
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
      </div>

      <hr class="my-4" />

      <div class="grid grid-cols-8 gap-8">
        <div class="col-span-2">
          <Navigation.nav_menu passages={@passages} current_passage={@passage} />
        </div>
        <div class="col-span-3 overflow-y-auto max-h-screen mb-8">
          <.live_component
            id={:reader}
            module={TextServerWeb.ReadingEnvironment.Reader}
            comments={@comments}
            focused_text_node={@focused_text_node}
            footnotes={@footnotes}
            location={@location}
            passage={@passage}
            text_nodes={@text_nodes}
            version_urn={@version.urn}
          />
        </div>
        <div class="col-span-3 overflow-y-scroll max-h-screen">
          <%= for comment <- @comments do %>
            <.live_component
              id={comment.id}
              module={TextServerWeb.ReadingEnvironment.CollapsibleComment}
              comment={comment}
              is_highlighted={Enum.member?(@highlighted_comments, Map.get(comment, :id))}
            />
          <% end %>
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
      Commentaries.list_canonical_commentaries()
      |> Enum.map(fn c -> %{id: c.id, label: c.pid, selected: false} end)
      |> build_options()

    comments = filter_comments(text_nodes, commentaries)

    {:noreply,
     socket
     |> assign(
       commentaries: commentaries,
       comments: comments,
       commentary_filter_changeset:
         commentaries
         |> build_changeset(),
       form: to_form(params),
       highlighted_comments: [],
       passage: passage,
       passages: Passages.list_passages_for_version(version),
       page_title: version.label,
       text_nodes: text_nodes |> TextNodes.tag_text_nodes(comments),
       version: version
     )}
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

    {:noreply, socket |> assign(highlighted_comments: ids)}
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
  def handle_info({:focused_text_node, text_node}, socket) do
    {:noreply, socket |> assign(focused_text_node: text_node)}
  end

  def handle_info({:updated_options, options}, socket) do
    # update the list of comments, the selected selected_commentaries and the changeset in the form
    {:noreply, assign_multi_select_options(socket, options)}
  end

  defp assign_multi_select_options(socket, commentaries) do
    text_nodes = socket.assigns.text_nodes
    comments = filter_comments(text_nodes, commentaries)
    text_nodes = TextNodes.tag_text_nodes(socket.assigns.text_nodes, comments)

    socket
    |> assign(
      commentary_filter_changeset: build_changeset(commentaries),
      comments: comments,
      commentaries: commentaries,
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
  end

  defp build_changeset(options) do
    %MultiSelect{}
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_embed(:options, options)
  end

  defp filter_comments(text_nodes, options) do
    selected_options =
      Enum.flat_map(options, fn option ->
        if option.selected in [true, "true"] do
          [option.id]
        else
          []
        end
      end)

    Comments.filter_comments(
      text_nodes |> Enum.map(& &1.id),
      selected_options
    )
    |> Enum.sort_by(&{&1.start_text_node.offset, &1.start_offset})
  end
end
