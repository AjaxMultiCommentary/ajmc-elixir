defmodule TextServer.Ingestion.Ajmc do
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

  defp commentaries_meta_path do
    Application.app_dir(:text_server, "priv/commentaries.toml")
  end
end
