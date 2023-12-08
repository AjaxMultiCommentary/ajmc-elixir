defmodule TextServer.Repo.Migrations.AddLabelAndUrnToVersionPassages do
  use Ecto.Migration

  def up do
    alter table(:version_passages) do
      add :label, :string
      add :urn, :map, null: false
    end

    TextServer.Repo.delete_all(TextServer.Versions.Passage)

    flush()

    create unique_index(:version_passages, [:urn])
  end

  def down do
    drop unique_index(:version_passages, [:urn])

    alter table(:version_passages) do
      remove(:label)
      remove(:urn)
    end
  end
end
