defmodule TextServerWeb.IiifController do
  use TextServerWeb, :controller

  alias TextServer.Accounts.Authorization
  alias TextServer.Commentaries

  @doc """
  Check whether the user can view the commentary,
  then (if the user is authorized) send the image matching the requested page.

  /iiif/DeRomilly1976/DeRomilly1976_0037/full/max/0/default.png
  """
  def show(conn, %{"commentary_pid" => commentary_pid, "image" => image}) do
    commentary = Commentaries.get_canonical_commentary_by(%{pid: commentary_pid})

    if Authorization.can_view_commentary?(conn.assigns.current_user, commentary) do
      full_path = get_image(commentary_pid <> "/" <> Enum.join(image, "/"))

      send_file(conn, 200, full_path)
    else
      send_resp(conn, 404, "Not found")
    end
  end

  defp get_image(path) do
    Application.app_dir(:text_server, "priv/static/ajmc_iiif/#{path}")
  end
end
