defmodule TextServerWeb.VersionController do
  use TextServerWeb, :controller

  alias TextServer.Repo
  alias TextServer.Versions

  def download(conn, %{"id" => id}) do
    version = Versions.get_version!(id)

    send_download(conn, {:file, version.filename})
  end

  def lemmas(conn, %{
        "collection" => collection,
        "text_group" => text_group,
        "version" => version,
        "work" => work
      }) do
    version =
      Versions.get_version_by_urn!("urn:cts:#{collection}:#{text_group}.#{work}.#{version}")
      |> Repo.preload(commentaries: :lemmas)

    json(conn, Enum.map(version.commentaries, fn c -> c.lemmas end))
  end

  def show(conn, %{
        "collection" => collection,
        "text_group" => text_group,
        "version" => version,
        "work" => work
      }) do
    version =
      Versions.get_version_by_urn!("urn:cts:#{collection}:#{text_group}.#{work}.#{version}")
      |> Repo.preload(:xml_document)

    {:ok, doc} = DataSchema.to_struct(version.xml_document, DataSchemas.Version)

    json(conn, doc)
  end
end
