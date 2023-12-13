defmodule TextServer.Repo.Migrations.AddZoteroFieldsToCanonicalCommentaries do
  use Ecto.Migration

  def change do
    alter table(:canonical_commentaries) do
      add :zotero_id, :string
      add :creator_first_name, :string, null: false
      add :creator_last_name, :string, null: false
      add :languages, {:array, :string}, null: false
      add :publication_date, :integer, null: false
      add :source_url, :string
      add :title, :string, null: false
      add :zotero_link, :string
    end
  end
end
