defmodule TextServer.Repo.Migrations.AddUrnToCommentariesAndComments do
  use Ecto.Migration

  def change do
    alter table(:canonical_commentaries) do
      add :urn, :map
    end

    alter table(:comments) do
      add :urn, :map
    end
  end
end
