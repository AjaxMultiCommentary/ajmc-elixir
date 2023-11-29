defmodule TextServer.Repo.Migrations.AddCanonicalCommentaryIdToTextElements do
  use Ecto.Migration

  def change do
    alter table(:text_elements) do
      add :canonical_commentary_id, references(:canonical_commentaries, on_delete: :delete_all)
    end

    create index(:text_elements, [:canonical_commentary_id])
  end
end
