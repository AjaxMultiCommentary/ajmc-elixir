defmodule TextServer.Comments.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "comments" do
    field :attributes, :map
    field :content, :string
    field :lemma, :string
    field :lemma_urn, TextServer.Ecto.Types.CTS_URN
    field :start_offset, :integer
    field :end_offset, :integer

    belongs_to :canonical_commentary, TextServer.Commentaries.CanonicalCommentary
    belongs_to :start_text_node, TextServer.TextNodes.TextNode
    belongs_to :end_text_node, TextServer.TextNodes.TextNode

    timestamps()
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:attributes, :content, :lemma, :lemma_urn, :start_offset, :end_offset])
    |> validate_required([:attributes, :content, :lemma, :lemma_urn, :start_offset, :end_offset])
    |> assoc_constraint(:canonical_commentary)
    |> assoc_constraint(:start_text_node)
    |> assoc_constraint(:end_text_node)
  end
end
