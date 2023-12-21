defmodule TextServerWeb.TextNodeLiveTest do
  use TextServerWeb.ConnCase

  import Phoenix.LiveViewTest
  import TextServer.TextNodesFixtures

  defp create_text_node(_) do
    text_node = text_node_fixture()
    %{text_node: text_node}
  end

  describe "Index" do
    setup [:create_text_node]

    test "lists all text_nodes", %{conn: conn, text_node: text_node} do
      {:ok, _index_live, html} = live(conn, Routes.text_node_index_path(conn, :index))

      assert html =~ "TextNodes"
      assert html =~ text_node.text
    end

    test "deletes text_node in listing", %{conn: conn, text_node: text_node} do
      {:ok, index_live, _html} = live(conn, Routes.text_node_index_path(conn, :index))

      assert index_live |> element("#text_node-#{text_node.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#text_node-#{text_node.id}")
    end
  end
end
