defmodule TextServer.TextElements.TextElement do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:attributes, :content, :canonical_commentary]}

  schema "text_elements" do
    field :attributes, :map
    field :content, :string
    field :end_offset, :integer
    field :start_offset, :integer

    belongs_to :canonical_commentary, TextServer.Commentaries.CanonicalCommentary
    belongs_to :element_type, TextServer.ElementTypes.ElementType
    belongs_to :end_text_node, TextServer.TextNodes.TextNode
    belongs_to :start_text_node, TextServer.TextNodes.TextNode

    many_to_many :text_element_users, TextServer.Accounts.User,
      join_through: TextServer.TextElements.User

    timestamps()
  end

  @doc false
  def changeset(text_element, attrs) do
    text_element
    |> cast(attrs, [
      :attributes,
      :canonical_commentary_id,
      :content,
      :element_type_id,
      :end_offset,
      :end_text_node_id,
      :start_offset,
      :start_text_node_id
    ])
    |> validate_required([:attributes, :end_offset, :start_offset])
    |> assoc_constraint(:canonical_commentary)
    |> assoc_constraint(:element_type)
    |> assoc_constraint(:end_text_node)
    |> assoc_constraint(:start_text_node)
  end
end
