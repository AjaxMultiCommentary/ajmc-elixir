defmodule TextServer.Commentaries do
  @moduledoc """
  The Commentaries context.
  """

  import Ecto.Query, warn: false
  alias TextServer.Repo

  alias TextServer.Commentaries.CanonicalCommentary

  @doc """
  Returns the list of canonical_commentaries.

  ## Examples

      iex> list_canonical_commentaries()
      [%CanonicalCommentary{}, ...]

  """
  def list_canonical_commentaries do
    Repo.all(CanonicalCommentary)
  end

  @doc """
  Gets a single canonical_commentary.

  Raises `Ecto.NoResultsError` if the Canonical commentary does not exist.

  ## Examples

      iex> get_canonical_commentary!(123)
      %CanonicalCommentary{}

      iex> get_canonical_commentary!(456)
      ** (Ecto.NoResultsError)

  """
  def get_canonical_commentary!(id), do: Repo.get!(CanonicalCommentary, id)

  @doc """
  Creates a canonical_commentary.

  ## Examples

      iex> create_canonical_commentary(%{field: value})
      {:ok, %CanonicalCommentary{}}

      iex> create_canonical_commentary(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_canonical_commentary(attrs \\ %{}) do
    %CanonicalCommentary{}
    |> CanonicalCommentary.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Inserts or updates a canonical commentary.
  """
  def upsert_canonical_commentary(attrs) do
    pid = Map.get(attrs, :pid, Map.get(attrs, "pid"))
    query = from(c in CanonicalCommentary, where: c.pid == ^pid)

    case Repo.one(query) do
      nil -> create_canonical_commentary(attrs)
      commentary -> update_canonical_commentary(commentary, attrs)
    end
  end

  @doc """
  Updates a canonical_commentary.

  ## Examples

      iex> update_canonical_commentary(canonical_commentary, %{field: new_value})
      {:ok, %CanonicalCommentary{}}

      iex> update_canonical_commentary(canonical_commentary, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_canonical_commentary(%CanonicalCommentary{} = canonical_commentary, attrs) do
    canonical_commentary
    |> CanonicalCommentary.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a canonical_commentary.

  ## Examples

      iex> delete_canonical_commentary(canonical_commentary)
      {:ok, %CanonicalCommentary{}}

      iex> delete_canonical_commentary(canonical_commentary)
      {:error, %Ecto.Changeset{}}

  """
  def delete_canonical_commentary(%CanonicalCommentary{} = canonical_commentary) do
    Repo.delete(canonical_commentary)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking canonical_commentary changes.

  ## Examples

      iex> change_canonical_commentary(canonical_commentary)
      %Ecto.Changeset{data: %CanonicalCommentary{}}

  """
  def change_canonical_commentary(%CanonicalCommentary{} = canonical_commentary, attrs \\ %{}) do
    CanonicalCommentary.changeset(canonical_commentary, attrs)
  end
end
