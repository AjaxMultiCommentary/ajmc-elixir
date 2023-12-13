defmodule TextServerWeb.VersionLive.Show do
  use TextServerWeb, :live_view

  alias TextServerWeb.Components
  alias TextServerWeb.ReadingEnvironment.Navigation

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
        <div class="col-span-3">
          <.live_component
            id={:reader}
            module={TextServerWeb.ReadingEnvironment.Reader}
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
      <Components.pagination current_page={@passage.passage_number} total_pages={@passage.total_passages} />
    </article>
    """
  end

  @impl true
  def handle_params(%{"urn" => urn, "page" => passage_number} = params, _, socket) do
    version = Versions.get_version_by_urn!(urn)
    create_response(socket, params, version, get_passage(version.id, passage_number))
  end

  def handle_params(%{"urn" => urn, "location" => raw_location} = params, _session, socket) do
    version = Versions.get_version_by_urn!(urn)

    location = raw_location |> String.split(".") |> Enum.map(&String.to_integer/1)

    passage_page = get_passage_by_location(version.id, location)

    if is_nil(passage_page) do
      {:noreply, socket |> put_flash(:error, "No text nodes found for the given passage.")}
    else
      create_response(socket, params, version, passage_page)
    end
  end

  def handle_params(params, session, socket) do
    handle_params(
      params |> Enum.into(%{"page" => "1"}),
      session,
      socket
    )
  end

  defp create_response(socket, params, version, page) do
    %{comments: comments, footnotes: footnotes, passage: passage} = page

    sibling_versions =
      Versions.list_sibling_versions(version)
      |> Enum.map(fn v ->
        [key: v.label, value: Integer.to_string(v.id), selected: version.id == v.id]
      end)

    commentaries =
      Commentaries.list_canonical_commentaries()
      |> Enum.map(fn c -> %{id: c.id, label: c.pid, selected: false} end)
      |> build_options()

    text_nodes = passage.text_nodes

    {:noreply,
     socket
     |> assign(
       commentaries: commentaries,
       comments: comments,
       commentary_filter_changeset:
         commentaries
         |> build_changeset(),
       footnotes: footnotes,
       form: to_form(params),
       highlighted_comments: [],
       passage: Map.delete(passage, :text_nodes),
       passages: Passages.list_passages_for_version(version),
       page_title: version.label,
       versions: sibling_versions,
       text_nodes: text_nodes |> TextNodes.tag_text_nodes(),
       version: version
     )}
  end

  def format_toc(toc, top_level_location, second_level_location) do
    {format_top_level_toc(toc, top_level_location),
     format_second_level_toc(toc, top_level_location, second_level_location)}
  end

  def format_toc(toc, top_level_location) do
    {format_top_level_toc(toc, top_level_location), nil}
  end

  @spec format_second_level_toc(map(), pos_integer(), pos_integer()) :: [
          [key: String.t(), value: String.t(), selected: boolean()]
        ]
  def format_second_level_toc(toc, top_level_location, location \\ 1) do
    Map.get(toc, top_level_location)
    |> Map.keys()
    |> Enum.sort()
    |> Enum.map(&[key: "Chapter #{&1}", value: &1, selected: &1 == location])
  end

  @spec format_top_level_toc(map(), pos_integer()) :: [
          [key: String.t(), value: String.t(), selected: boolean()]
        ]
  def format_top_level_toc(toc, location \\ 1) do
    Map.keys(toc)
    |> Enum.sort()
    |> Enum.map(&[key: "Book #{&1}", value: &1, selected: &1 == location])
  end

  @impl true
  def handle_event("highlight-comments", %{"comments" => comment_ids}, socket) do
    ids =
      comment_ids
      |> Jason.decode!()

    {:noreply, socket |> assign(highlighted_comments: ids)}
  end

  def handle_event("location-change", location, socket) do
    version_id = Map.get(location, "version_select")
    top_level = Map.get(location, "top_level_location") |> String.to_integer()
    second_level = Map.get(location, "second_level_location") |> String.to_integer()

    toc = Versions.get_table_of_contents(version_id)

    top_level_toc = format_top_level_toc(toc, top_level)
    second_level_toc = format_second_level_toc(toc, top_level, second_level)

    versions =
      socket.assigns.versions
      |> Enum.map(fn v ->
        id = Keyword.get(v, :value)
        Keyword.merge(v, selected: id == version_id)
      end)

    {:noreply,
     socket
     |> assign(
       second_level_toc: second_level_toc,
       versions: versions,
       top_level_toc: top_level_toc
     )}
  end

  def handle_event("change-location", location, socket) do
    top_level = Map.get(location, "top_level_location")
    second_level = Map.get(location, "second_level_location")
    version_id = Map.get(location, "version_select", socket.assigns.version.id)
    location_s = "#{top_level}.#{second_level}.1"

    {:noreply, socket |> push_patch(to: "/versions/#{version_id}?location=#{location_s}")}
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

  def handle_info({:version_command_palette_open, state}, socket) do
    {:noreply, socket |> assign(version_command_palette_open: state)}
  end

  def handle_info({:updated_options, options}, socket) do
    # update the list of comments, the selected selected_commentaries and the changeset in the form
    {:noreply, assign_multi_select_options(socket, options)}
  end

  defp get_passage(version_id, passage_number) when is_binary(passage_number),
    do: get_passage(version_id, String.to_integer(passage_number))

  defp get_passage(version_id, passage_number) do
    passage = Versions.get_version_passage(version_id, passage_number)

    organize_passage(passage)
  end

  defp get_passage_by_location(version_id, location) when is_list(location) do
    passage = Versions.get_version_passage_by_location(version_id, location)

    organize_passage(passage)
  end

  defp organize_passage(passage) when is_nil(passage), do: nil

  defp organize_passage(passage) do
    elements =
      passage.text_nodes
      |> Enum.map(fn tn -> tn.text_elements end)
      |> List.flatten()

    comments =
      elements
      |> Enum.filter(fn te ->
        te.element_type.name == "comment"
      end)
      |> Enum.map(fn c ->
        Map.merge(c, %{
          author: c.text_element_users |> Enum.map(& &1.email) |> Enum.join(", "),
          date: c.updated_at
        })
      end)

    footnotes =
      elements
      |> Enum.filter(fn te -> te.element_type.name == "note" end)

    %{comments: comments, footnotes: footnotes, passage: passage}
  end

  defp assign_multi_select_options(socket, commentaries) do
    socket
    |> assign(:commentary_filter_changeset, build_changeset(commentaries))
    |> assign(
      :comments,
      filter_comments(commentaries, get_all_comments(socket.assigns.text_nodes))
    )
    |> assign(:commentaries, commentaries)
  end

  defp get_all_comments(text_nodes) do
    text_nodes
    |> Enum.map(fn tn -> tn.text_elements end)
    |> List.flatten()
    |> Enum.filter(fn te ->
      te.element_type.name == "comment"
    end)
    |> Enum.map(fn c ->
      Map.merge(c, %{
        author: c.text_element_users |> Enum.map(& &1.email) |> Enum.join(", "),
        date: c.updated_at
      })
    end)
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

  defp filter_comments(options, comments) do
    selected_options =
      Enum.flat_map(options, fn option ->
        if option.selected in [true, "true"] do
          [option.id]
        else
          []
        end
      end)

    if selected_options == [] do
      comments
    else
      comments
      |> Enum.filter(fn c ->
        Enum.member?(selected_options, c.canonical_commentary_id)
      end)
    end
  end
end
