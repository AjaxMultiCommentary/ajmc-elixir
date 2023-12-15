defmodule TextServer.Repo.Migrations.AddZoteroFieldsToCanonicalCommentaries do
  use Ecto.Migration

  def change do
    alter table(:canonical_commentaries) do
      add :zotero_id, :string
      add :creator_first_name, :string
      add :creator_last_name, :string
      add :languages, {:array, :string}
      add :publication_date, :integer
      add :source_url, :string
      add :title, :string
      add :zotero_link, :string
    end
  end
end
