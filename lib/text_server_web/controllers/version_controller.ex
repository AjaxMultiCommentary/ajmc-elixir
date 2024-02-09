defmodule TextServerWeb.VersionController do
  use TextServerWeb, :controller

  alias TextServer.Versions

  def download(conn, %{"id" => id}) do
    version = Versions.get_version!(id)

    send_download(conn, {:file, version.filename})
  end
end
