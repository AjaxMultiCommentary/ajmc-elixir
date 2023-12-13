defmodule TextServer.Repo.Migrations.CreateComments do
  use Ecto.Migration

  def change do
    create table(:comments) do
      add :content, :text
      add :lemma, :string
      add :attributes, :map, null: false
      add :start_offset, :integer, null: false
      add :end_offset, :integer, null: false

      add :canonical_commentary_id, references(:canonical_commentaries, on_delete: :nothing)
      add :start_text_node_id, references(:text_nodes, on_delete: :nothing)
      add :end_text_node_id, references(:text_nodes, on_delete: :nothing)

      timestamps()
    end

    create index(:comments, [:canonical_commentary_id])
    create index(:comments, [:start_text_node_id])
    create index(:comments, [:end_text_node_id])
  end
end
