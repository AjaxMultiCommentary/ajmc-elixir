defmodule TextServerWeb.IiifController do
  use TextServerWeb, :controller

  alias TextServer.Commentaries

  @doc """
  Check whether the user can view the commentary,
  then (if the user is authorized) send the image matching the requested page.

  /iiif/DeRomilly1976/DeRomilly1976_0037/full/max/0/default.png
  """
  def full_image(conn, %{"commentary_pid" => commentary_pid, "image_id" => image_id}) do
    current_user = conn.assigns.current_user
    commentary = Commentaries.get_canonical_commentary_by(%{pid: commentary_pid})

    with :ok <-
           Bodyguard.permit(Commentaries.CanonicalCommentary, :view, current_user, commentary) do
      image = get_image!(commentary_pid, image_id)

      conn
      |> put_resp_content_type("image/png")
      |> send_resp(200, Base.decode64!(image, ignore: :whitespace))
    else
      _ ->
        send_resp(conn, 404, "Not found")
    end
  end

  defp get_image!(commentary_id, image_id) do
    GitHub.API.get_image!(commentary_id, image_id)
  end
end
