defmodule TextServer.Commentaries.CanonicalCommentary do
  @behaviour Bodyguard.Policy

  alias TextServer.Accounts
  alias TextServer.Commentaries.CanonicalCommentary

  use Ecto.Schema

  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:filename, :pid]}

  schema "canonical_commentaries" do
    field :filename, :string
    field :languages, {:array, :string}
    field :pid, :string
    field :publication_date, :integer
    field :public_domain_year, :integer
    field :source_url, :string
    field :title, :string
    field :wikidata_qid, :string
    field :zotero_id, :string
    field :zotero_link, :string

    belongs_to :version, TextServer.Versions.Version

    many_to_many :creators, TextServer.Commentaries.Creator,
      join_through: TextServer.Commentaries.CommentaryCreator,
      on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(canonical_commentary, attrs) do
    canonical_commentary
    |> cast(attrs, [
      :filename,
      :languages,
      :pid,
      :publication_date,
      :public_domain_year,
      :source_url,
      :title,
      :wikidata_qid,
      :zotero_id,
      :zotero_link,
      :version_id
    ])
    |> validate_required([
      :filename,
      :languages,
      :pid,
      :publication_date,
      :title
    ])
    |> unique_constraint(:filename)
    |> unique_constraint(:pid)
    |> assoc_constraint(:version)
    |> cast_assoc(:creators, required: true)
  end

  @doc """
  Authorization behaviour right now is very simple:
  if a user is logged in, we assume they can view
  all commentaries; if not, we check if the commentary
  is public domain.
  """
  def authorize(_, %Accounts.User{}, _), do: true

  def authorize(_, nil, %CanonicalCommentary{} = commentary) do
    is_public_domain?(commentary)
  end

  def authorize(_, _, _), do: false

  def commentary_label(%CanonicalCommentary{} = commentary) do
    creators =
      case Enum.count(commentary.creators) do
        1 -> List.first(commentary.creators) |> Map.get(:last_name)
        2 -> Enum.map(commentary.creators, &Map.get(&1, :last_name)) |> Enum.join(" and ")
        _ -> (List.first(commentary.creators) |> Map.get(:last_name)) <> " et al."
      end

    "#{creators} #{commentary.publication_date}"
  end

  def is_public_domain?(%CanonicalCommentary{} = commentary) do
    commentary.public_domain_year < NaiveDateTime.utc_now().year()
  end
end
