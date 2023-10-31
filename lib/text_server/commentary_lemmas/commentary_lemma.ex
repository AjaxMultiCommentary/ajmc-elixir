defmodule TextServer.CommentaryLemmas.CommentaryLemma do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder,
           only: [
             :anchor_target,
             :label,
             :selector,
             :shifts,
             :text_anchor,
             :transcript,
             :canonical_commentary_id
           ]}

  schema "commentary_lemmas" do
    field :anchor_target, :map
    field :label, :string
    field :selector, :string
    field :shifts, {:array, :integer}
    field :text_anchor, :string
    field :transcript, :string

    belongs_to :canonical_commentary, TextServer.Commentaries.CanonicalCommentary

    timestamps()
  end

  @doc false
  def changeset(commentary_lemma, attrs) do
    commentary_lemma
    |> cast(attrs, [
      :anchor_target,
      :canonical_commentary_id,
      :label,
      :selector,
      :shifts,
      :text_anchor,
      :transcript
    ])
    |> unique_constraint([:canonical_commentary_id, :selector])
    |> assoc_constraint(:canonical_commentary)
  end
end
