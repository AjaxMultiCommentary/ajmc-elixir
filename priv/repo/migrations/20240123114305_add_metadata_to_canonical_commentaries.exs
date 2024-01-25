defmodule TextServer.Repo.Migrations.AddMetadataToCanonicalCommentaries do
  use Ecto.Migration

  def change do
    alter table(:canonical_commentaries) do
      add :metadata, :map
    end
  end
end
