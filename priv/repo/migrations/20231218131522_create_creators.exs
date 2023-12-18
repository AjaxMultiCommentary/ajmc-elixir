defmodule TextServer.Repo.Migrations.CreateCreators do
  use Ecto.Migration

  def up do
    create table(:creators) do
      add :first_name, :string
      add :last_name, :string
      add :creator_type, :string

      timestamps()
    end

    # flush()

    create table(:commentary_creators) do
      add :canonical_commentary_id, references(:canonical_commentaries)
      add :creator_id, references(:creators)

      timestamps()
    end

    create unique_index(:commentary_creators, [:canonical_commentary_id, :creator_id])
  end

  def down do
    drop unique_index(:commentary_creators, [:canonical_commentary_id, :creator_id])
    drop table(:commentary_creators)
    drop table(:creators)
  end
end
