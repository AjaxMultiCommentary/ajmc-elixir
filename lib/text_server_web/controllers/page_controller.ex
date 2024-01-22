defmodule TextServerWeb.PageController do
  use TextServerWeb, :controller

  def home(conn, _params) do
    conn
    |> redirect(to: ~p"/versions/urn:cts:greekLit:tlg0011.tlg003.ajmc-lj")
  end
end
