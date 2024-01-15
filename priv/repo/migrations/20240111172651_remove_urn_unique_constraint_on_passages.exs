defmodule TextServer.Repo.Migrations.RemoveUrnUniqueConstraintOnPassages do
  use Ecto.Migration

  def change do
    drop_if_exists index(:version_passages, [:urn])

    alter table(:version_passages) do
      modify :start_location, {:array, :string}, from: {:array, :integer}
      modify :end_location, {:array, :string}, from: {:array, :integer}
    end
  end
end
