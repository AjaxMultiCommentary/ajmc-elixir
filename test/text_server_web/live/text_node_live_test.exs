defmodule TextServerWeb.TextNodeLiveTest do
  use TextServerWeb.ConnCase

  import Phoenix.LiveViewTest
  import TextServer.TextNodesFixtures

  @create_attrs %{
    location: [1, 1, 1],
    text: "some text"
  }
  @update_attrs %{
    location: [1, 1, 1],
    text: "some updated text"
  }
  @invalid_attrs %{index: nil, location: [], normalized_text: nil, text: nil}

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

    test "updates text_node in listing", %{conn: conn, text_node: text_node} do
      {:ok, index_live, _html} = live(conn, Routes.text_node_index_path(conn, :index))

      assert index_live |> element("#text_node-#{text_node.id} a", "Edit") |> render_click() =~
               "Edit Text node"

      assert_patch(index_live, Routes.text_node_index_path(conn, :edit, text_node))

      assert index_live
             |> form("#text_node-form", text_node: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#text_node-form", text_node: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.text_node_index_path(conn, :index))

      assert html =~ "Text node updated successfully"
      assert html =~ "some updated text"
    end

    test "deletes text_node in listing", %{conn: conn, text_node: text_node} do
      {:ok, index_live, _html} = live(conn, Routes.text_node_index_path(conn, :index))

      assert index_live |> element("#text_node-#{text_node.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#text_node-#{text_node.id}")
    end
  end

  describe "Show" do
    setup [:create_text_node]

    test "displays text_node", %{conn: conn, text_node: text_node} do
      {:ok, _show_live, html} = live(conn, Routes.text_node_show_path(conn, :show, text_node))

      assert html =~ "Show Text node"
    end
  end
end
