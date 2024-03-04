defmodule TextServerWeb.PageControllerTest do
  use TextServerWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 302)
  end

  test "GET /about", %{conn: conn} do
    conn = get(conn, ~p"/about")

    assert html_response(conn, 200)
    assert conn.resp_body =~ "Ajax Multi-Commentary\n– About"
  end

  test "GET /bibliography", %{conn: conn} do
    conn = get(conn, ~p"/bibliography")

    assert html_response(conn, 200)
    assert conn.resp_body =~ "Ajax Multi-Commentary\n– Bibliography"
  end
end
