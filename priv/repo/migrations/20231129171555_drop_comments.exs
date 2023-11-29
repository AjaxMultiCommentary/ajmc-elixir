defmodule TextServer.Repo.Migrations.DropComments do
  use Ecto.Migration

  def change do
    drop table(:comments)
  end
end
