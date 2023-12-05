defmodule TextServer.LemmalessComments do
  @moduledoc """
  The LemmalessComments context.
  """

  import Ecto.Query, warn: false
  alias TextServer.Repo

  alias TextServer.LemmalessComments.LemmalessComment

  @doc """
  Returns the list of lemmaless_comments.

  ## Examples

      iex> list_lemmaless_comments()
      [%LemmalessComment{}, ...]

  """
  def list_lemmaless_comments do
    Repo.all(LemmalessComment)
  end

  @doc """
  Gets a single lemmaless_comment.

  Raises `Ecto.NoResultsError` if the Lemmaless comment does not exist.

  ## Examples

      iex> get_lemmaless_comment!(123)
      %LemmalessComment{}

      iex> get_lemmaless_comment!(456)
      ** (Ecto.NoResultsError)

  """
  def get_lemmaless_comment!(id), do: Repo.get!(LemmalessComment, id)

  @doc """
  Creates a lemmaless_comment.

  ## Examples

      iex> create_lemmaless_comment(%{field: value})
      {:ok, %LemmalessComment{}}

      iex> create_lemmaless_comment(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_lemmaless_comment(attrs \\ %{}) do
    %LemmalessComment{}
    |> LemmalessComment.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a lemmaless_comment.

  ## Examples

      iex> update_lemmaless_comment(lemmaless_comment, %{field: new_value})
      {:ok, %LemmalessComment{}}

      iex> update_lemmaless_comment(lemmaless_comment, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_lemmaless_comment(%LemmalessComment{} = lemmaless_comment, attrs) do
    lemmaless_comment
    |> LemmalessComment.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a lemmaless_comment.

  ## Examples

      iex> delete_lemmaless_comment(lemmaless_comment)
      {:ok, %LemmalessComment{}}

      iex> delete_lemmaless_comment(lemmaless_comment)
      {:error, %Ecto.Changeset{}}

  """
  def delete_lemmaless_comment(%LemmalessComment{} = lemmaless_comment) do
    Repo.delete(lemmaless_comment)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking lemmaless_comment changes.

  ## Examples

      iex> change_lemmaless_comment(lemmaless_comment)
      %Ecto.Changeset{data: %LemmalessComment{}}

  """
  def change_lemmaless_comment(%LemmalessComment{} = lemmaless_comment, attrs \\ %{}) do
    LemmalessComment.changeset(lemmaless_comment, attrs)
  end
end
