defmodule TextServer.Languages do
  @moduledoc """
  The Languages context.
  """

  import Ecto.Query, warn: false
  require Logger
  alias TextServer.Repo

  alias TextServer.Languages.Language

  @doc """
  Returns the list of languages.

  ## Examples

      iex> list_languages()
      [%Language{}, ...]

  """
  def list_languages do
    Repo.all(Language)
  end

  @doc """
  Gets a single language.

  Raises `Ecto.NoResultsError` if the Language does not exist.

  ## Examples

      iex> get_language!(123)
      %Language{}

      iex> get_language!(456)
      ** (Ecto.NoResultsError)

  """
  def get_language!(id), do: Repo.get!(Language, id)

  # should probably rename this column to iso_code or something
  def get_language_by_slug(slug) do
    query = from(l in Language, where: l.slug == ^slug)

    Repo.one(query)
  end

  def get_language_by_iso_code(iso_code) do
    get_language_by_slug(iso_code)
  end

  def get_language_by_iso_code!(iso_code) do
    query = from(l in Language, where: l.slug == ^iso_code)

    Repo.one!(query)
  end

  @doc """
  Creates a language.

  ## Examples

      iex> create_language(%{field: value})
      {:ok, %Language{}}

      iex> create_language(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_language(attrs \\ %{}) do
    %Language{}
    |> Language.changeset(attrs)
    |> Repo.insert()
  end

  def find_or_create_language_by_iso_code(iso_code) do
    case get_language_by_iso_code(iso_code) do
      nil ->
        title = get_title_by_iso_code(iso_code)

        case create_language(%{slug: iso_code, title: title}) do
          {:ok, language} ->
            {:ok, language}

          {:error, _reason} ->
            Logger.warning("Unable to create language iso_code: #{iso_code}, title: #{title}")
            nil
        end

      language ->
        {:ok, language}
    end
  end

  def find_or_create_language(%{slug: slug, title: _title}) do
    case get_by_slug(slug) do
      nil ->
        title = get_title_by_iso_code(slug)
        create_language(%{slug: slug, title: title})

      language ->
        {:ok, language}
    end
  end

  def find_or_create_language(attrs) do
    # this is a weird query, but it's checking for erroneous XML
    query = from(l in Language, where: l.title == ^attrs[:title] or l.slug == ^attrs[:title])

    case Repo.one(query) do
      nil ->
        attrs = Map.put_new(attrs, :slug, Recase.to_kebab(attrs[:title]))
        {:ok, _new_language} = create_language(attrs)

      language ->
        {:ok, language}
    end
  end

  def get_by_slug(slug) when is_binary(slug) do
    cleaned_slug =
      case String.downcase(slug) do
        "eng" -> "en"
        "greek" -> "grc"
        _ -> slug
      end

    Repo.get_by(Language, slug: cleaned_slug)
  end

  def get_by_slug(nil) do
    Repo.get_by(Language, slug: "en")
  end

  def get_title_by_iso_code(iso_code) do
    case String.downcase(iso_code) do
      "arc" -> "Aramaic"
      "cop" -> "Coptic"
      "en" -> "English"
      "enm" -> "Middle English"
      "fr" -> "French"
      "frm" -> "Middle French"
      "fro" -> "Old French"
      "ger" -> "German"
      "grc" -> "Greek"
      "gre" -> "Modern Greek"
      "he" -> "Hebrew"
      "heb" -> "Hebrew"
      "it" -> "Italian"
      "lat" -> "Latin"
      _ -> Recase.to_sentence(iso_code)
    end
  end

  @doc """
  Updates a language.

  ## Examples

      iex> update_language(language, %{field: new_value})
      {:ok, %Language{}}

      iex> update_language(language, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_language(%Language{} = language, attrs) do
    language
    |> Language.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a language.

  ## Examples

      iex> delete_language(language)
      {:ok, %Language{}}

      iex> delete_language(language)
      {:error, %Ecto.Changeset{}}

  """
  def delete_language(%Language{} = language) do
    Repo.delete(language)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking language changes.

  ## Examples

      iex> change_language(language)
      %Ecto.Changeset{data: %Language{}}

  """
  def change_language(%Language{} = language, attrs \\ %{}) do
    Language.changeset(language, attrs)
  end
end
