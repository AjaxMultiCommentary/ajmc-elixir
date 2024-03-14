defmodule TextServer.Repo.Migrations.AddPublisherPlaceAndEditionToCanonicalCommentaries do
  use Ecto.Migration

  def change do
    alter table(:canonical_commentaries) do
      add :edition, :string, default: "1"
      add :place, :string
      add :publisher, :string
    end
  end
end
