defmodule TextServer.Repo.Migrations.LemmalessComments do
  use Ecto.Migration

  def up do
    create table(:lemmaless_comments) do
      add :content, :text
      add :attributes, :map
      add :urn, :map
      add :canonical_commentary_id, references(:canonical_commentaries, on_delete: :nothing)
      add :start_text_node_id, references(:text_nodes, on_delete: :nothing)
      add :end_text_node_id, references(:text_nodes, on_delete: :nothing)

      timestamps()
    end

    execute "CREATE EXTENSION IF NOT EXISTS pg_trgm;"

    execute """
      CREATE INDEX lemmaless_comments_content_gin_trgm_idx
        ON lemmaless_comments
        USING gin (content gin_trgm_ops);
    """

    create index(:lemmaless_comments, [:canonical_commentary_id])
    create index(:lemmaless_comments, [:start_text_node_id])
    create index(:lemmaless_comments, [:end_text_node_id])
  end

  def down do
    drop index(:lemmaless_comments, [:canonical_commentary_id])
    drop index(:lemmaless_comments, [:start_text_node_id])
    drop index(:lemmaless_comments, [:end_text_node_id])

    execute """
    DROP INDEX lemmaless_comments_content_gin_tgrm_idx;
    """

    drop table(:lemmaless_comments)
  end
end
