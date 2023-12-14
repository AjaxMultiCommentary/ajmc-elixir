defmodule TextServer.Repo.Migrations.DropProjects do
  use Ecto.Migration

  def change do
    drop table(:project_versions)
    drop table(:project_users)
    drop table(:project_exemplars)
    drop table(:project_cover_images)
    drop table(:cover_images)
    drop table(:projects)
  end
end
