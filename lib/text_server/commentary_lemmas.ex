defmodule TextServer.CommentaryLemmas do
  @moduledoc """
  The CommentaryLemmas context.
  """

  import Ecto.Query, warn: false
  alias TextServer.Repo

  alias TextServer.CommentaryLemmas.CommentaryLemma

  @doc """
  Returns the list of commentary_lemmas.

  ## Examples

      iex> list_commentary_lemmas()
      [%CommentaryLemma{}, ...]

  """
  def list_commentary_lemmas do
    Repo.all(CommentaryLemma)
  end

  @doc """
  Gets a single commentary_lemma.

  Raises `Ecto.NoResultsError` if the Commentary lemma does not exist.

  ## Examples

      iex> get_commentary_lemma!(123)
      %CommentaryLemma{}

      iex> get_commentary_lemma!(456)
      ** (Ecto.NoResultsError)

  """
  def get_commentary_lemma!(id), do: Repo.get!(CommentaryLemma, id)

  @doc """
  Creates a commentary_lemma.

  ## Examples

      iex> create_commentary_lemma(%{field: value})
      {:ok, %CommentaryLemma{}}

      iex> create_commentary_lemma(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_commentary_lemma(attrs \\ %{}) do
    %CommentaryLemma{}
    |> CommentaryLemma.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Inserts or updates a commentary lemma.
  """
  def upsert_commentary_lemma(attrs) do
    canonical_commentary_id =
      Map.get(attrs, :canonical_commentary_id, Map.get(attrs, "canonical_commentary_id"))

    selector = Map.get(attrs, :selector, Map.get(attrs, "selector"))

    if is_nil(selector) do
      nil
    else
      query =
        from(l in CommentaryLemma,
          where:
            l.canonical_commentary_id == ^canonical_commentary_id and
              l.selector == ^selector
        )

      case Repo.one(query) do
        nil -> create_commentary_lemma(attrs)
        lemma -> update_commentary_lemma(lemma, attrs)
      end
    end
  end

  @doc """
  Updates a commentary_lemma.

  ## Examples

      iex> update_commentary_lemma(commentary_lemma, %{field: new_value})
      {:ok, %CommentaryLemma{}}

      iex> update_commentary_lemma(commentary_lemma, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_commentary_lemma(%CommentaryLemma{} = commentary_lemma, attrs) do
    commentary_lemma
    |> CommentaryLemma.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a commentary_lemma.

  ## Examples

      iex> delete_commentary_lemma(commentary_lemma)
      {:ok, %CommentaryLemma{}}

      iex> delete_commentary_lemma(commentary_lemma)
      {:error, %Ecto.Changeset{}}

  """
  def delete_commentary_lemma(%CommentaryLemma{} = commentary_lemma) do
    Repo.delete(commentary_lemma)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking commentary_lemma changes.

  ## Examples

      iex> change_commentary_lemma(commentary_lemma)
      %Ecto.Changeset{data: %CommentaryLemma{}}

  """
  def change_commentary_lemma(%CommentaryLemma{} = commentary_lemma, attrs \\ %{}) do
    CommentaryLemma.changeset(commentary_lemma, attrs)
  end
end
