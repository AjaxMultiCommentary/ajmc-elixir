defmodule TextServer.Ingestion.Ajmc do
  def run do
    [version | _rest] = TextServer.Ingestion.Versions.create_versions()

    for p <- commentary_paths() do
      TextServer.Ingestion.Commentary.ingest_commentary(CTS.URN.to_string(version.urn), p)
    end
  end

  defp commentary_paths do
    {:ok, files} = File.ls("priv/static/json")

    files |> Enum.map(&("priv/static/json/" <> &1))
  end
end
