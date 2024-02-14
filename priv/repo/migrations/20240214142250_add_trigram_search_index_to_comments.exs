defmodule TextServer.Repo.Migrations.AddTrigramSearchIndexToComments do
  use Ecto.Migration

  def change do
    execute("CREATE EXTENSION IF NOT EXISTS unaccent;", "DROP EXTENSION IF EXISTS unaccent;")

    execute(
      """
      CREATE OR REPLACE FUNCTION f_unaccent(text)
          RETURNS text
          LANGUAGE sql IMMUTABLE PARALLEL SAFE AS
        $func$
          SELECT public.unaccent('public.unaccent', $1)
        $func$;
      """,
      "DROP FUNCTION IF EXISTS f_unaccent(text);"
    )

    execute("DROP INDEX IF EXISTS lemmaless_comments_content_gin_trgm_idx;", "")

    execute(
      """
        CREATE INDEX IF NOT EXISTS lemmaless_comments_content_gin_trgm_idx
          ON lemmaless_comments
          USING gin (f_unaccent(content) gin_trgm_ops);
      """,
      "DROP INDEX IF EXISTS lemmaless_comments_content_gin_trgm_idx;"
    )

    execute(
      """
        CREATE INDEX IF NOT EXISTS comments_content_gin_trgm_idx
          ON comments
          USING gin (f_unaccent(content) gin_trgm_ops);
      """,
      "DROP INDEX IF EXISTS comments_content_gin_tgrm_idx;"
    )
  end
end
