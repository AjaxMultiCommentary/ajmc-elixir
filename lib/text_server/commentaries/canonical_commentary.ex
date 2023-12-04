defmodule TextServer.Commentaries.CanonicalCommentary do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:filename, :pid]}

  schema "canonical_commentaries" do
    field :filename, :string
    field :pid, :string

    belongs_to :version, TextServer.Versions.Version

    timestamps()
  end

  @doc false
  def changeset(canonical_commentary, attrs) do
    canonical_commentary
    |> cast(attrs, [:filename, :pid, :version_id])
    |> validate_required([:filename, :pid])
    |> unique_constraint(:filename)
    |> unique_constraint(:pid)
    |> assoc_constraint(:version)
  end
end
