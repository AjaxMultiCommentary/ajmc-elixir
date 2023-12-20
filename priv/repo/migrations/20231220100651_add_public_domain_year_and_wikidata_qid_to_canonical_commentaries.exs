defmodule TextServer.Repo.Migrations.AddPublicDomainYearAndWikidataQidToCanonicalCommentaries do
  use Ecto.Migration

  def up do
    alter table(:canonical_commentaries) do
      add :public_domain_year, :integer
      add :wikidata_qid, :string
    end
  end

  def down do
    alter table(:canonical_commentaries) do
      remove :public_domain_year
      remove :wikidata_qid
    end
  end
end
