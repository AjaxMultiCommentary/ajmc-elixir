defmodule TextServer.Repo.Migrations.CreateCommentaryLemmas do
  use Ecto.Migration

  def change do
    create table(:commentary_lemmas) do
      add :label, :string
      add :shifts, {:array, :integer}
      add :transcript, :string
      add :anchor_target, :map
      add :text_anchor, :string
      add :selector, :string
      add :canonical_commentary_id, references(:canonical_commentaries, on_delete: :delete_all)

      timestamps()
    end

    create index(:commentary_lemmas, [:canonical_commentary_id])
  end
end
