defmodule TextServer.Ingestion.Ajmc do
  def run do
    TextServer.Repo.delete_all(TextServer.TextElements.TextElement)
    TextServer.Repo.delete_all(TextServer.Comments.Comment)
    TextServer.Repo.delete_all(TextServer.Versions.Version)

    [version | _rest] = TextServer.Ingestion.Versions.create_versions()

    for p <- commentary_paths() do
      TextServer.Ingestion.Commentary.ingest_commentary(CTS.URN.to_string(version.urn), p)
    end
  end

  defp commentary_paths do
    Path.wildcard(Application.app_dir(:text_server, "priv/static/json/*_tess_retrained.json"))
  end
end
