defmodule TextServer.Repo.Migrations.RemoveTextNodeRelationOnComments do
  use Ecto.Migration

  def change do
    drop_if_exists index(:lemmaless_comments, [:start_text_node_id])
    drop_if_exists index(:lemmaless_comments, [:end_text_node_id])

    drop_if_exists index(:comments, [:start_text_node_id])
    drop_if_exists index(:comments, [:end_text_node_id])

    alter table(:comments) do
      remove :start_text_node_id
      remove :end_text_node_id
    end

    alter table(:lemmaless_comments) do
      remove :start_text_node_id
      remove :end_text_node_id
    end
  end
end
