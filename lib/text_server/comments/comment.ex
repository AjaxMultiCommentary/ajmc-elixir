defmodule TextServer.Comments.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "comments" do
    field :attributes, :map
    field :content, :string
    field :lemma, :string
    field :start_offset, :integer
    field :end_offset, :integer
    field :urn, TextServer.Ecto.Types.CTS_URN
    field :interface_id, :string, virtual: true

    belongs_to :canonical_commentary, TextServer.Commentaries.CanonicalCommentary

    timestamps()
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [
      :attributes,
      :canonical_commentary_id,
      :content,
      :end_offset,
      :lemma,
      :start_offset,
      :urn
    ])
    |> validate_required([
      :attributes,
      :canonical_commentary_id,
      :content,
      :end_offset,
      :lemma,
      :start_offset,
      :urn
    ])
    |> assoc_constraint(:canonical_commentary)
  end
end
