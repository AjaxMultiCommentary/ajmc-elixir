defmodule TextServer.Repo.Migrations.AddOffsetToTextNodes do
  use Ecto.Migration

  def change do
    alter table(:text_nodes) do
      add :offset, :integer
    end

    create unique_index(:text_nodes, [:version_id, :offset])
  end
end
