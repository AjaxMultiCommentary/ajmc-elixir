defmodule TextServerWeb.PageController do
  use TextServerWeb, :controller

  def home(conn, _params) do
    conn
    |> put_root_layout(false)
    |> render(:home, layout: false)
  end

  def redirect_to_locale(conn, %{"urn" => urn}) do
    locale = Gettext.get_locale(TextServerWeb.Gettext)

    redirect(conn, to: ~p"/#{locale}/versions/#{urn}")
  end

  def redirect_to_locale(conn, _params) do
    locale = Gettext.get_locale(TextServerWeb.Gettext)

    redirect(conn, to: ~p"/#{locale}")
  end
end
