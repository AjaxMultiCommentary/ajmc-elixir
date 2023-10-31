defmodule TextServer.Repo.Migrations.CreateCanonicalCommentaries do
  use Ecto.Migration

  def change do
    create table(:canonical_commentaries) do
      add :pid, :string, null: false
      add :filename, :string, null: false
      add :version_id, references(:versions, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:canonical_commentaries, [:filename])
    create unique_index(:canonical_commentaries, [:pid])
    create index(:canonical_commentaries, [:version_id])
  end
end
