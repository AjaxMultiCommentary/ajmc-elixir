defmodule TextServer.Versions.Passages do
  @moduledoc """
  This module mainly exists to prevent the main context module
  from becoming too large.

  This module handles fetching passages for a given location
  in a version. In particular, it is useful for working out
  efficient ways to fetch from the XML documents.
  """

  import Ecto.Query, warn: false
  alias TextServer.Repo

  alias TextServer.Versions.Passage
  alias TextServer.Versions.Version
  alias TextServer.Versions.XmlDocuments
  alias TextServer.Versions.XmlDocuments.XmlDocument

  def create_passage!(attrs \\ %{}) do
    %Passage{}
    |> Passage.changeset(attrs)
    |> Repo.insert!()
  end

  def create_passage(attrs \\ %{}) do
    %Passage{}
    |> Passage.changeset(attrs)
    |> Repo.insert()
  end

  def find_or_create_passage(attrs \\ %{}) do
    query =
      from(p in Passage, where: p.urn == ^attrs[:urn])

    case Repo.one(query) do
      nil -> create_passage(attrs)
      passage -> {:ok, passage}
    end
  end

  def list_passages() do
    Repo.all(Passage)
  end

  def list_passages_for_version(%Version{} = version) do
    from(
      p in Passage,
      where: p.version_id == ^version.id,
      order_by: p.passage_number
    )
    |> Repo.all()
  end

  @doc """
  Returns a list of tuples representing possible passage references. The index + 1
  of a given tuple in the list corresponds to its "page" in the readable
  representation of the work.

  So, for example, for Pausanias, this function returns a list like

      [
        {{"1", "1"}, 1},
        {{"1", "2"}, 2},
        {{"1", "3"}, 3},
        {{"1", "4"}, 4},
        {{"1", "5"}, 5},
        {{"1", "6"}, 6},
        {{"1", "7"}, ...},
        {...},
        ...
      ]

  Page 1 is indicated by the 0th tuple, {{"1", "1"}, 1}, which can be used to look up all
  of the passages for 1.1 in the table (map) of contents. Similarly,
  Page 5 is indicatd by the 4th tuple, {{"1", "5"}, 5}, and can be used to look up
  all passages for 1.5 in the table of contents.
  """
  def list_passage_refs(%XmlDocument{} = document) do
    {:ok, toc} = XmlDocuments.get_table_of_contents(document)

    list_passage_refs(toc)
  end

  def list_passage_refs(toc) when is_list(toc) do
    passages =
      toc
      |> Enum.group_by(fn ref ->
        {elem(ref, 0), elem(ref, 1)}
      end)

    keys = Map.keys(passages)

    {:ok, Enum.sort_by(keys, &{String.to_integer(elem(&1, 0)), String.to_integer(elem(&1, 1))})}
  end
end
