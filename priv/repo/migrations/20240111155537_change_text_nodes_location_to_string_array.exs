defmodule TextServer.Repo.Migrations.ChangeTextNodesLocationToStringArray do
  use Ecto.Migration

  def change do
    alter table(:text_nodes) do
      modify :location, {:array, :string}, from: {:array, :integer}
    end
  end
end
