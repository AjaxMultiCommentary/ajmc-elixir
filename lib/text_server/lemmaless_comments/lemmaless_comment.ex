defmodule TextServer.LemmalessComments.LemmalessComment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "lemmaless_comments" do
    field :attributes, :map
    field :content, :string
    field :urn, :map
    field :canonical_commentary_id, :id
    field :start_text_node_id, :id
    field :end_text_node_id, :id

    timestamps()
  end

  @doc false
  def changeset(lemmaless_comment, attrs) do
    lemmaless_comment
    |> cast(attrs, [:content, :attributes, :urn])
    |> validate_required([:content])
  end
end
