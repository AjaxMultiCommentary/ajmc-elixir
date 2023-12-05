defmodule TextServerWeb.LemmalessCommentControllerTest do
  use TextServerWeb.ConnCase

  import TextServer.LemmalessCommentsFixtures

  alias TextServer.LemmalessComments.LemmalessComment

  @create_attrs %{
    attributes: %{},
    content: "some content",
    urn: %{}
  }
  @update_attrs %{
    attributes: %{},
    content: "some updated content",
    urn: %{}
  }
  @invalid_attrs %{attributes: nil, content: nil, urn: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all lemmaless_comments", %{conn: conn} do
      conn = get(conn, ~p"/api/lemmaless_comments")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create lemmaless_comment" do
    test "renders lemmaless_comment when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/lemmaless_comments", lemmaless_comment: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/lemmaless_comments/#{id}")

      assert %{
               "id" => ^id,
               "attributes" => %{},
               "content" => "some content",
               "urn" => %{}
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/lemmaless_comments", lemmaless_comment: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update lemmaless_comment" do
    setup [:create_lemmaless_comment]

    test "renders lemmaless_comment when data is valid", %{conn: conn, lemmaless_comment: %LemmalessComment{id: id} = lemmaless_comment} do
      conn = put(conn, ~p"/api/lemmaless_comments/#{lemmaless_comment}", lemmaless_comment: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/lemmaless_comments/#{id}")

      assert %{
               "id" => ^id,
               "attributes" => %{},
               "content" => "some updated content",
               "urn" => %{}
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, lemmaless_comment: lemmaless_comment} do
      conn = put(conn, ~p"/api/lemmaless_comments/#{lemmaless_comment}", lemmaless_comment: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete lemmaless_comment" do
    setup [:create_lemmaless_comment]

    test "deletes chosen lemmaless_comment", %{conn: conn, lemmaless_comment: lemmaless_comment} do
      conn = delete(conn, ~p"/api/lemmaless_comments/#{lemmaless_comment}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/lemmaless_comments/#{lemmaless_comment}")
      end
    end
  end

  defp create_lemmaless_comment(_) do
    lemmaless_comment = lemmaless_comment_fixture()
    %{lemmaless_comment: lemmaless_comment}
  end
end
