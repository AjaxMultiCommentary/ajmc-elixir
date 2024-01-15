defmodule TextServer.Repo.Migrations.CreateRepositories do
  use Ecto.Migration

  alias TextServer.Collections
  alias TextServer.Repo
  alias TextServer.TextGroups

  def up do
    create table(:repositories) do
      add(:url, :string)
      add(:collection_id, references(:collections, on_delete: :nothing))

      timestamps()
    end

    create(unique_index(:repositories, [:url]))
    create(index(:repositories, [:collection_id]))

    # We need to drop this index for now and deal with the
    # conflicts when we migrate text_groups to have unique
    # urn_fragments
    drop unique_index(:text_groups, [:collection_id, :urn])

    flush()

    collections_by_namespace = Collections.list_collections()
    |> Repo.preload(:text_groups)
    |> Enum.group_by(&Map.get(&1, :urn_fragment))

    collections_by_namespace
    |> Enum.each(fn {namespace, collections} ->
      [collection | rest] = collections
      urls = collections |> Enum.map(& Map.get(&1, :repository))

      urls |> Enum.each(fn url ->
        {:ok, _repository} = Collections.create_repository(%{collection_id: collection.id, url: url})
      end)

      rest |> Enum.each(fn extra_collection ->
        extra_collection.text_groups
        # move all text_groups to the first collection
        |> Enum.each(fn text_group ->
          {:ok, _tg} = TextGroups.update_text_group(text_group, %{collection_id: collection.id})
        end)

        Collections.delete_collection(extra_collection)
      end)
    end)

    flush()

    create(unique_index(:collections, [:urn]))
    create(unique_index(:collections, [:urn_fragment]))
  end

  def down do
    drop(unique_index(:repositories, [:url]))
    drop(index(:repositories, [:collection_id]))
    drop(table(:repositories))
  end
end
