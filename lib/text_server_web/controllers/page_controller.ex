defmodule TextServerWeb.PageController do
  use TextServerWeb, :controller

  alias TextServer.StaticPages

  def home(conn, _params) do
    conn
    |> redirect(to: ~p"/versions/urn:cts:greekLit:tlg0011.tlg003.ajmc-lj")
  end

  def about(conn, _params) do
    about = StaticPages.all_pages() |> Enum.find(fn page -> page.id == "about" end)

    conn
    |> render("page.html", page: about)
  end
end
