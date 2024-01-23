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

  def list_lemmaless_comments(current_user) when is_nil(current_user) do
    public_commentaries_query()
    |> Repo.all()
  end

  def list_lemmaless_comments(_current_user) do
    list_lemmaless_comments()
  end

  def list_lemmaless_comments_for_lines(current_user, first_line_n, last_line_n)
      when is_nil(current_user) do
    range = Range.new(first_line_n, last_line_n) |> Range.to_list()
    query = public_commentaries_query()

    from(
      q in query,
      where: fragment("(? -> ? ->> 0)::int", q.urn, "citations") in ^range
    )
    |> Repo.all()
  end

  def list_lemmaless_comments_for_lines(_current_user, first_line_n, last_line_n) do
    range = Range.new(first_line_n, last_line_n) |> Range.to_list()

    LemmalessComment
    |> where([c], fragment("(? -> ? ->> 0)::int", c.urn, "citations") in ^range)
    |> preload(canonical_commentary: :creators)
    |> Repo.all()
  end

  def filter_lemmaless_comments(current_user, comentary_ids, first_line_n, last_line_n)
      when length(comentary_ids) == 0 do
    list_lemmaless_comments_for_lines(current_user, first_line_n, last_line_n)
  end

  def filter_lemmaless_comments(current_user, commentary_ids, first_line_n, last_line_n)
      when is_nil(current_user) do
    range = Range.new(first_line_n, last_line_n) |> Range.to_list()
    query = public_commentaries_query()

    from(
      c in query,
      where:
        fragment("(? -> ? ->> 0)::int", c.urn, "citations") in ^range and
          c.canonical_commentary_id in ^commentary_ids
    )
    |> Repo.all()
  end

  def filter_lemmaless_comments(_current_user, commentary_ids, first_line_n, last_line_n) do
    range = Range.new(first_line_n, last_line_n) |> Range.to_list()

    LemmalessComment
    |> where([c], fragment("(? -> ? ->> 0)::int", c.urn, "citations") in ^range)
    |> where([c], c.canonical_commentary_id in ^commentary_ids)
    |> preload(canonical_commentary: :creators)
    |> Repo.all()
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

  def get_lemmaless_comment_by_urn!(%CTS.URN{} = urn) do
    LemmalessComment
    |> where([c], c.urn == ^urn)
    |> Repo.one!()
  end

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
  Upserts a lemmaless_comment.
  """
  def upsert_lemmaless_comment(attrs) do
    query =
      from(c in LemmalessComment,
        where: c.canonical_commentary_id == ^attrs.canonical_commentary_id and c.urn == ^attrs.urn
      )

    case Repo.one(query) do
      nil -> create_lemmaless_comment(attrs)
      comment -> update_lemmaless_comment(comment, attrs)
    end
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

  def with_interface_id(%LemmalessComment{} = comment) do
    %{comment | interface_id: "lemmaless_comment-#{comment.id}"}
  end

  defp public_commentaries_query do
    from(c in LemmalessComment,
      join: parent in assoc(c, :canonical_commentary),
      where:
        parent.public_domain_year < ^NaiveDateTime.utc_now().year() and
          not is_nil(parent.public_domain_year),
      preload: [canonical_commentary: :creators]
    )
  end
end
