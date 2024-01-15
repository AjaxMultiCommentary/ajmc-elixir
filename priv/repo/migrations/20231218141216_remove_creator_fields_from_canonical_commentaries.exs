defmodule TextServer.Repo.Migrations.RemoveCreatorFieldsFromCanonicalCommentaries do
  use Ecto.Migration

  def up do
    alter table(:canonical_commentaries) do
      remove_if_exists(:creator_first_name, :string)
      remove_if_exists(:creator_last_name, :string)
    end
  end

  def down do
    alter table(:canonical_commentaries) do
      add_if_not_exists :creator_first_name, :string
      add_if_not_exists :creator_last_name, :string
    end
  end
end
