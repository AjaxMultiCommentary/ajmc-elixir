defmodule TextServer.TextNodes do
  @moduledoc """
  The TextNodes context.
  """

  import Ecto.Query, warn: false
  alias TextServer.Repo

  alias TextServer.TextNodes.TextNode
  alias TextServer.Versions
  alias TextServer.Versions.Version

  @doc """
  Returns the list of text_nodes.

  ## Examples

      iex> list_text_nodes()
      [%TextNode{}, ...]

  """
  def list_text_nodes do
    Repo.paginate(TextNode)
  end

  @doc """
  Returns a paginated list of text_nodes with their text_elements,
  based on version_id.

  This function is especially useful for the ReadingEnvironment.

  ## Examples

      iex> list_text_nodes_by_version_id(1, [page_size: 20, page: 2])
      %Scrivener.Page{
        entries: [
          %TextNode{
            text_elements: [%TextElement{}, ...],
            ...
          },
          ...
        ],
        page_number: 2,
        page_size: 20,
        total_pages: 4
      }
  """
  def list_text_nodes_by_version_id(version_id, params \\ [page_size: 20]) do
    query =
      from(
        t in TextNode,
        where: t.version_id == ^version_id,
        order_by: [asc: t.location],
        preload: [text_elements: :element_type]
      )

    Repo.paginate(query, params)
  end

  @doc """
  Returns an ordered list of TextNode locations for the given version.

  ## Examples

      iex> list_text_node_locations_by_version_id(1)
      [[1, 1, 1], [1, 1, 2], [1, 1, 3], ...]
  """

  def list_locations_by_version_id(version_id) do
    query =
      from(
        t in TextNode,
        where: t.version_id == ^version_id,
        order_by: [asc: t.location],
        select: t.location
      )

    Repo.all(query)
  end

  @doc """
  Lists TextNodes from other versions of the same work
  at the same location.
  """
  def list_text_node_critica(nil), do: []

  def list_text_node_critica([%TextNode{}] = text_nodes) do
    [tn | _rest] = text_nodes
    version_ids = Versions.list_versions_for_urn(tn.urn) |> Enum.reject(&(&1 == tn.version_id))
    locations = Enum.map(text_nodes, & &1.location)

    from(
      t in TextNode,
      where: t.version_id in ^version_ids and t.location in ^locations,
      limit: 10,
      preload: :version
    )
    |> Repo.all()
  end

  def list_text_node_critica(%TextNode{} = text_node) do
    version_ids =
      Versions.list_versions_for_urn(text_node.urn)
      |> Enum.reject(&(&1.id == text_node.version_id))
      |> Enum.map(& &1.id)

    from(
      t in TextNode,
      where: t.version_id in ^version_ids and t.location == ^text_node.location,
      limit: 10,
      preload: :version
    )
    |> Repo.all()
  end

  @doc """
  Returns a list of TextNodes between start_location and end_location.

  Used by Exemplars.get_version_page/2 and Exemplars.get_version_page_by_location/2.

  FIXME: Currently this is an n+2 query because of the need to get the
  offsets. I'm not sure that there's a good way to fix that without
  causing more problems with how the passages are recorded.

  ## Examples

      iex> list_text_nodes_by_version_between_locations(%Version{id: 1}, [1, 1, 1], [1, 1, 2])
      [%TextNode{location: [1, 1, 1], ...}, %TextNode{location: [1, 1, 2], ...}]
  """
  def list_text_nodes_by_version_between_locations(
        %Version{} = version,
        start_location,
        end_location
      ) do
    with first_text_node when not is_nil(first_text_node) <-
           get_text_node_by(%{location: start_location, version_id: version.id}),
         last_text_node when not is_nil(last_text_node) <-
           get_text_node_by(%{location: end_location, version_id: version.id}) do
      # FIXME: Using the end_location like this is a bit of a hack to get around the
      # fact that not every line exists or is numbered in every edition.
      query =
        from(
          t in TextNode,
          where:
            t.version_id == ^version.id and
              t.offset >= ^first_text_node.offset and
              t.offset <= ^last_text_node.offset,
          order_by: [asc: t.offset],
          preload: [
            :version,
            text_elements: [:element_type, :text_element_users]
          ]
        )

      Repo.all(query)
    end
  end

  def list_text_nodes_by_version_between_locations(version_id, start_location, end_location)
      when is_integer(version_id) do
    list_text_nodes_by_version_between_locations(
      %Version{id: version_id},
      start_location,
      end_location
    )
  end

  def list_text_nodes_by_version_between_locations(version_id, start_location, end_location)
      when is_binary(version_id) do
    list_text_nodes_by_version_between_locations(
      %Version{id: version_id},
      start_location,
      end_location
    )
  end

  @spec list_text_nodes_by_version_from_start_location(%Version{}, [...]) :: [%TextNode{}]
  def list_text_nodes_by_version_from_start_location(%Version{} = version, start_location) do
    cardinality = Enum.count(start_location)
    pseudo_page_number = Enum.at(start_location, cardinality - 2)

    query =
      from(
        t in TextNode,
        where:
          t.version_id == ^version.id and
            t.location >= ^start_location and
            fragment("location[?] = ?", ^cardinality - 1, ^pseudo_page_number) and
            fragment("location[1] = ?", ^List.first(start_location)),
        order_by: [asc: t.location],
        preload: [text_elements: [:canonical_commentary, :element_type, :text_element_users]]
      )

    Repo.all(query)
  end

  def tag_text_nodes(text_nodes, comments \\ []) do
    Enum.map(text_nodes, &TextNode.tag_graphemes(&1, comments))
  end

  @doc """
  Gets a single text_node.

  Raises `Ecto.NoResultsError` if the Text node does not exist.

  ## Examples

      iex> get_text_node!(123)
      %TextNode{}

      iex> get_text_node!(456)
      ** (Ecto.NoResultsError)

  """
  def get_text_node!(id) do
    Repo.get!(TextNode, id)
    |> Repo.preload([:version, text_elements: [:element_type, :text_element_users]])
  end

  def get_text_node_by(attrs \\ %{}) do
    Repo.get_by(TextNode, attrs)
  end

  @doc """
  Creates a text_node.

  ## Examples

      iex> create_text_node(%{field: value})
      {:ok, %TextNode{}}

      iex> create_text_node(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_text_node(attrs \\ %{}) do
    %TextNode{}
    |> TextNode.changeset(attrs)
    |> Repo.insert()
  end

  def find_or_create_text_node(attrs) do
    location =
      attrs[:location]
      |> Enum.map(fn l ->
        if is_binary(l) do
          l
        else
          Integer.to_string(l)
        end
      end)

    query =
      from(t in TextNode,
        where: t.version_id == ^attrs[:version_id] and t.location == ^location
      )

    case Repo.one(query) do
      nil -> create_text_node(attrs)
      text_node -> {:ok, text_node}
    end
  end

  @doc """
  Updates a text_node.

  ## Examples

      iex> update_text_node(text_node, %{field: new_value})
      {:ok, %TextNode{}}

      iex> update_text_node(text_node, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_text_node(%TextNode{} = text_node, attrs) do
    text_node
    |> TextNode.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a text_node.

  ## Examples

      iex> delete_text_node(text_node)
      {:ok, %TextNode{}}

      iex> delete_text_node(text_node)
      {:error, %Ecto.Changeset{}}

  """
  def delete_text_node(%TextNode{} = text_node) do
    Repo.delete(text_node)
  end

  def delete_text_nodes_by_version_id(version_id) do
    query =
      from(
        t in TextNode,
        where: t.version_id == ^version_id
      )

    Repo.delete_all(query)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking text_node changes.

  ## Examples

      iex> change_text_node(text_node)
      %Ecto.Changeset{data: %TextNode{}}

  """
  def change_text_node(%TextNode{} = text_node, attrs \\ %{}) do
    TextNode.changeset(text_node, attrs)
  end

  def with_interface_id(%TextNode{} = text_node) do
    %{text_node | interface_id: "line-#{text_node.location |> Enum.join("-")}"}
  end
end
