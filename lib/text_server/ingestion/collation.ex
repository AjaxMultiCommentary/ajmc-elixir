defmodule TextServer.Ingestion.Collation do
  alias TextServer.TextNodes
  alias TextServer.Versions

  def prepare_versions do
    witnesses =
      Versions.list_versions()
      |> Enum.reject(fn version -> version.urn.version == "ajmc-lobeck" end)
      |> Enum.map(fn version ->
        text_nodes =
          TextNodes.list_text_nodes_by_version_between_locations(version, ["693"], ["718"])

        %{
          id: CTS.URN.to_string(version.urn),
          tokens:
            Enum.flat_map(text_nodes, fn tn ->
              tn.text
              |> String.split(~r/[[:space:]]/u)
              |> Enum.map(fn t ->
                %{
                  t: t,
                  n: t |> String.trim() |> String.replace(~r/[[:punct:]]/u, ""),
                  location: tn.location |> List.first()
                }
              end)
            end)
        }
      end)

    File.write!("for_collation.json", Jason.encode!(%{witnesses: witnesses}))
  end
end
