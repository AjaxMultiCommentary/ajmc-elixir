defmodule TextServer.Commentaries.CanonicalCommentary do
  @behaviour Bodyguard.Policy

  alias TextServer.Accounts
  alias TextServer.Commentaries.CanonicalCommentary

  use Ecto.Schema

  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:filename, :pid, :metadata]}

  schema "canonical_commentaries" do
    field :filename, :string
    field :languages, {:array, :string}
    field :metadata, :map
    field :pid, :string
    field :publication_date, :integer
    field :public_domain_year, :integer
    field :source_url, :string
    field :title, :string
    field :urn, TextServer.Ecto.Types.CTS_URN
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
      :metadata,
      :pid,
      :publication_date,
      :public_domain_year,
      :source_url,
      :title,
      :urn,
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
      :title,
      :urn
    ])
    |> unique_constraint(:filename)
    |> unique_constraint(:pid)
    |> unique_constraint(:urn)
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

  def creators_to_string(creators) when length(creators) == 0 do
    "Anonymous"
  end

  def creators_to_string(creators) when length(creators) == 1 do
    creator = creators |> List.first()

    "#{creator.last_name}, #{creator.first_name}"
  end

  def creators_to_string(creators) when length(creators) > 1 do
    [creator | rest] = creators

    s = "#{creator.last_name}, #{creator.first_name}"

    last = List.last(rest)

    rest = (rest -- [last]) |> Enum.map(fn c -> "#{c.first_name} #{c.last_name}" end)

    "#{s}, #{Enum.join(rest, ",")}, and #{last.first_name} #{last.last_name}"
  end

  def is_public_domain?(%CanonicalCommentary{} = commentary) do
    commentary.public_domain_year < NaiveDateTime.utc_now().year()
  end
end
