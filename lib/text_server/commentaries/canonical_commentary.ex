defmodule TextServer.Commentaries.CanonicalCommentary do
  alias TextServer.Commentaries.CanonicalCommentary
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:filename, :pid]}

  schema "canonical_commentaries" do
    field :filename, :string
    field :languages, {:array, :string}
    field :pid, :string
    field :publication_date, :integer
    field :source_url, :string
    field :title, :string
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
      :source_url,
      :title,
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

  def commentary_label(%CanonicalCommentary{} = commentary) do
    creators =
      case Enum.count(commentary.creators) do
        1 -> List.first(commentary.creators) |> Map.get(:last_name)
        2 -> Enum.map(commentary.creators, &Map.get(&1, :last_name)) |> Enum.join(" and ")
        _ -> (List.first(commentary.creators) |> Map.get(:last_name)) <> " et al."
      end

    "#{creators} #{commentary.publication_date}"
  end
end
