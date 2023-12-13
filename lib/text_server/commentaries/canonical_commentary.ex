defmodule TextServer.Commentaries.CanonicalCommentary do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:filename, :pid]}

  schema "canonical_commentaries" do
    field :creator_first_name, :string
    field :creator_last_name, :string
    field :filename, :string
    field :languages, {:array, :string}
    field :pid, :string
    field :publication_date, :integer
    field :source_url, :string
    field :title, :string
    field :zotero_id, :string
    field :zotero_link, :string

    belongs_to :version, TextServer.Versions.Version

    timestamps()
  end

  @doc false
  def changeset(canonical_commentary, attrs) do
    canonical_commentary
    |> cast(attrs, [
      :creator_first_name,
      :creator_last_name,
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
      :creator_first_name,
      :creator_last_name,
      :filename,
      :languages,
      :pid,
      :publication_date,
      :title
    ])
    |> unique_constraint(:filename)
    |> unique_constraint(:pid)
    |> assoc_constraint(:version)
  end
end
