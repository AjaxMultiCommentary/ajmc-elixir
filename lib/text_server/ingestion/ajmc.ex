defmodule TextServer.Ingestion.Ajmc do
  require Logger

  def run do
    TextServer.Repo.delete_all(TextServer.TextElements.TextElement)
    TextServer.Repo.delete_all(TextServer.Comments.Comment)
    TextServer.Repo.delete_all(TextServer.LemmalessComments.LemmalessComment)
    TextServer.Repo.delete_all(TextServer.TextNodes.TextNode)
    TextServer.Repo.delete_all(TextServer.Versions.Version)
    TextServer.Repo.delete_all(TextServer.Versions.Passage)

    TextServer.Ingestion.Versions.create_versions()

    File.read!(commentaries_meta_path())
    |> Toml.decode!()
    |> Map.get("commentaries")
    |> Enum.filter(fn c -> Map.get(c, "zotero_id") != "" end)
    |> Enum.each(&TextServer.Ingestion.Commentary.ingest_commentary/1)
  end

  def get_unique_wikidata_ids do
    entities_by_commentary =
      File.read!(commentaries_meta_path())
      |> Toml.decode!()
      |> Map.get("commentaries")
      |> Enum.filter(fn c -> Map.get(c, "zotero_id") != "" end)
      |> Enum.reduce(%{}, fn c, acc ->
        ajmc_id = c["ajmc_id"]

        Logger.info("Getting entities for #{ajmc_id}...")

        tess_retrained = GitHub.API.get_tess_retrained_file!(ajmc_id)
        json = GitHub.API.get_commentary_data!(tess_retrained["download_url"])

        entities =
          json
          |> Map.get("children")
          |> Map.get("entities")
          |> TextServer.Ingestion.Commentary.group_primary_full_entities()
          |> Enum.reject(&is_nil/1)
          |> List.flatten()
          |> Enum.filter(&(Map.get(&1, "label") == "work.primlit"))
          |> Enum.map(&Map.get(&1, "wikidata_id"))
          |> Enum.reject(&is_nil/1)

        Map.put(acc, ajmc_id, entities)
      end)

    all_entities = Map.values(entities_by_commentary) |> List.flatten() |> Enum.uniq()
    ids = Map.put(entities_by_commentary, :all, all_entities)

    File.write("wikidata_ids.json", Jason.encode!(ids, pretty: true))
  end

  defp commentaries_meta_path do
    Application.app_dir(:text_server, "priv/commentaries.toml")
  end
end
