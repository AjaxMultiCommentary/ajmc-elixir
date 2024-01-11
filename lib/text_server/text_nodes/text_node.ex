defmodule TextServer.TextNodes.TextNode do
  use Ecto.Schema
  import Ecto.Changeset

  schema "text_nodes" do
    # FIXME: (charles) Eventually, location will need to
    # be an array of strings, not integers. Consider citations for
    # Plato, Aristotle, etc.
    field :location, {:array, :string}
    field :normalized_text, :string
    field :offset, :integer
    field :text, :string
    field :urn, TextServer.Ecto.Types.CTS_URN
    field :_search, TextServer.Ecto.Types.TsVector

    field :graphemes_with_tags, :any, virtual: true

    belongs_to :version, TextServer.Versions.Version

    has_many :text_elements, TextServer.TextElements.TextElement,
      foreign_key: :start_text_node_id,
      preload_order: [asc: :start_offset]

    timestamps()
  end

  @doc false
  def changeset(text_node, attrs) do
    text_node
    |> cast(attrs, [:version_id, :location, :offset, :text, :urn])
    |> validate_required([:location, :offset, :text, :urn])
    |> assoc_constraint(:version)
    |> unique_constraint([:version_id, :location, :urn])
    |> unique_constraint([:version_id, :offset])
  end

  @search_types %{location: {:array, :any}, search_string: :string, urn: :string}

  def search_changeset(attrs \\ %{}) do
    cast({%{}, @search_types}, attrs, [:location, :search_string, :urn])
    |> validate_required([:search_string])
    |> update_change(:search_string, &String.trim/1)
    |> validate_length(:search_string, min: 2)
  end

  defmodule Tag do
    @enforce_keys [:name]

    defstruct [:name, :metadata]
  end

  def get_word_at_offset(text_node, offset, start_or_end \\ :start)

  def get_word_at_offset(text_node, offset, start_or_end) when is_nil(offset) do
    get_word_at_offset(text_node, 0, start_or_end)
  end

  def get_word_at_offset(text_node, offset, start_or_end) when is_binary(offset) do
    get_word_at_offset(text_node, String.to_integer(offset), start_or_end)
  end

  def get_word_at_offset(text_node, offset, :start) do
    {_before, s} = String.split_at(text_node.text, offset)

    s
    |> String.trim()
    |> String.graphemes()
    |> Enum.take_while(fn g -> Regex.match?(~r/[[:word:]]/u, g) end)
    |> Enum.join()
  end

  def get_word_at_offset(text_node, offset, :end) do
    {s, _after} = String.split_at(text_node.text, offset)

    s
    |> String.trim()
    |> String.graphemes()
    |> Enum.reverse()
    |> Enum.take_while(fn g -> Regex.match?(~r/[[:word:]]/u, g) end)
    |> Enum.reverse()
    |> Enum.join()
  end

  def tag_graphemes(text_node, comments) do
    elements =
      text_node.text_elements

    comments =
      comments
      |> Enum.filter(fn comment ->
        comment_start_location = comment.urn.citations |> Enum.at(0)
        comment_end_location = comment.urn.citations |> Enum.at(1)
        text_node_location = text_node.location |> Enum.at(0)

        # comment starts with this text node OR
        # comment ends on this text node OR
        # text node is in the middle of a multi-line comment
        comment_start_location == text_node_location or
          comment_end_location == text_node_location or
          (comment_start_location <= text_node_location and
             text_node_location <= comment_end_location)
      end)

    text = text_node.text

    # turn the bare graphemes list into an indexed list of tuples
    # representing the grapheme and associated inline metadata
    # Sort of akin to what ProseMirror does: https://prosemirror.net/docs/guide/#doc
    graphemes =
      String.graphemes(text)
      |> Enum.with_index(fn g, i -> {i, g, []} end)

    tagged_graphemes = apply_tags(elements, graphemes)
    commented_graphemes = apply_comments(text_node, comments, tagged_graphemes)

    grouped_graphemes =
      commented_graphemes
      |> Enum.reduce([], fn tagged_grapheme, acc ->
        {_i, g, tags} = tagged_grapheme
        first = List.first(acc)

        if first == nil do
          [{[g], tags}]
        else
          {g_list, first_tags} = first

          if first_tags == tags do
            List.replace_at(acc, 0, {g_list ++ [g], tags})
          else
            [{[g], tags} | acc]
          end
        end
      end)
      |> Enum.reverse()

    %{text_node | graphemes_with_tags: grouped_graphemes}
  end

  defp apply_tags(elements, graphemes) do
    Enum.reduce(elements, graphemes, fn el, gs ->
      tagged =
        gs
        |> Enum.map(fn g ->
          {i, g, tags} = g

          cond do
            el.element_type.name == "image" && i == el.start_offset - 1 ->
              {i, g,
               tags ++ [%Tag{name: el.element_type.name, metadata: %{src: el.content, id: el.id}}]}

            el.element_type.name == "note" && i == el.start_offset - 1 ->
              {i, g,
               tags ++
                 [%Tag{name: el.element_type.name, metadata: %{content: el.content, id: el.id}}]}

            i >= el.start_offset && i < el.end_offset ->
              {i, g,
               tags ++
                 [
                   %Tag{
                     name: el.element_type.name,
                     metadata: %{src: Map.get(el, :content), id: el.id}
                   }
                 ]}

            true ->
              {i, g, tags}
          end
        end)

      tagged
    end)
  end

  defp apply_comments(text_node, comments, graphemes) do
    graphemes
    |> Enum.map(fn g ->
      {i, g, tags} = g

      applicable_comments =
        comments
        |> Enum.filter(fn c ->
          text_node_location = Enum.at(text_node.location, 0)

          cond do
            # comment applies only to this text node
            Enum.at(c.urn.citations, 0) == Enum.at(c.urn.citations, 1) ->
              i in c.start_offset..(c.end_offset - 1)

            # comment starts on this text_node
            Enum.at(c.urn.citations, 0) == text_node_location ->
              i >= c.start_offset

            # comment ends on this text node
            Enum.at(c.urn.citations, 1) == text_node_location ->
              i <= c.end_offset

            # entire text node is in this comment
            true ->
              true
          end
        end)
        |> Enum.map(fn c -> %Tag{name: "comment", metadata: c} end)

      {i, g, tags ++ applicable_comments}
    end)
  end
end
