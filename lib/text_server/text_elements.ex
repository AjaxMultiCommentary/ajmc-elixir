defmodule TextServer.TextElements do
  @moduledoc """
  The TextElements context.
  """

  import Ecto.Query, warn: false
  alias TextServer.Repo

  alias TextServer.ElementTypes
  alias TextServer.TextElements.TextElement
  alias TextServer.TextNodes.TextNode

  @doc """
  Returns the list of text_elements.

  ## Examples

      iex> list_text_elements()
      [%TextElement{}, ...]

  """
  def list_text_elements do
    Repo.all(TextElement)
  end

  @spec list_text_elements_by_type(binary()) :: any()
  def list_text_elements_by_type(element_type) when is_binary(element_type) do
    case ElementTypes.get_element_type_by_name(element_type) do
      nil ->
        []

      el ->
        type_id = el.id
        query = from(t in TextElement, where: t.element_type_id == ^type_id)
        Repo.all(query)
    end
  end

  @doc """
  Gets a single text_element.

  Raises `Ecto.NoResultsError` if the Text element does not exist.

  ## Examples

      iex> get_text_element!(123)
      %TextElement{}

      iex> get_text_element!(456)
      ** (Ecto.NoResultsError)

  """
  def get_text_element!(id), do: Repo.get!(TextElement, id)

  def with_version(query) do
    from q in query, preload: [start_text_node: :version]
  end

  def get_text_elements(ids \\ []) do
    query = from(t in TextElement, where: t.id in ^ids)
    Repo.all(query)
  end

  @doc """
  Creates a text_element.

  ## Examples

      iex> create_text_element(%{field: value})
      {:ok, %TextElement{}}

      iex> create_text_element(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_text_element(attrs \\ %{}) do
    %TextElement{}
    |> TextElement.changeset(attrs)
    |> Repo.insert()
  end

  def find_or_create_text_element(attrs) do
    query =
      from(t in TextElement,
        where:
          t.element_type_id == ^attrs[:element_type_id] and
            t.end_offset == ^attrs[:end_offset] and
            t.end_text_node_id == ^attrs[:end_text_node_id] and
            t.start_offset == ^attrs[:start_offset] and
            t.start_text_node_id == ^attrs[:start_text_node_id]
      )

    case Repo.one(query) do
      nil -> create_text_element(attrs)
      element -> {:ok, element}
    end
  end

  def find_or_create_text_elements(%TextNode{} = text_node, text_elements) do
    text_elements
    |> Enum.map(fn el ->
      {:ok, element_type} =
        ElementTypes.find_or_create_element_type(%{name: Atom.to_string(el[:type])})

      {:ok, text_element} =
        find_or_create_text_element(
          el
          |> Map.delete(:type)
          |> Map.merge(%{
            element_type_id: element_type.id,
            # Right now, we follow Word's lead by assuming that an element does
            # not span multiple text nodes. Instead, a new element is created
            # for each text node that a single element would span.
            end_text_node_id: text_node.id,
            start_text_node_id: text_node.id
          })
          |> Map.put_new(:attributes, %{})
          |> Map.put_new(:end_offset, el[:start_offset])
        )

      maybe_upload_to_s3(el[:type], text_element)

      {:ok, {element_type, text_element}}
    end)
  end

  defp maybe_upload_to_s3(:image, text_element) do
    %{id: text_element.id}
    |> TextServer.Workers.S3Worker.new()
    |> Oban.insert()
  end

  defp maybe_upload_to_s3(_type_atom, _el), do: {:ok, nil}

  @doc """
  Updates a text_element.

  ## Examples

      iex> update_text_element(text_element, %{field: new_value})
      {:ok, %TextElement{}}

      iex> update_text_element(text_element, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_text_element(%TextElement{} = text_element, attrs) do
    text_element
    |> TextElement.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a text_element.

  ## Examples

      iex> delete_text_element(text_element)
      {:ok, %TextElement{}}

      iex> delete_text_element(text_element)
      {:error, %Ecto.Changeset{}}

  """
  def delete_text_element(%TextElement{} = text_element) do
    Repo.delete(text_element)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking text_element changes.

  ## Examples

      iex> change_text_element(text_element)
      %Ecto.Changeset{data: %TextElement{}}

  """
  def change_text_element(%TextElement{} = text_element, attrs \\ %{}) do
    TextElement.changeset(text_element, attrs)
  end
end
