defmodule TextServer.LemmalessCommentsTest do
  use TextServer.DataCase

  alias TextServer.LemmalessComments

  describe "lemmaless_comments" do
    alias TextServer.LemmalessComments.LemmalessComment

    import TextServer.LemmalessCommentsFixtures
    import TextServer.CommentariesFixtures

    @invalid_attrs %{attributes: nil, content: nil, urn: nil}

    test "list_lemmaless_comments/0 returns all lemmaless_comments" do
      lemmaless_comment = lemmaless_comment_fixture()
      assert LemmalessComments.list_lemmaless_comments() == [lemmaless_comment]
    end

    test "get_lemmaless_comment!/1 returns the lemmaless_comment with given id" do
      lemmaless_comment = lemmaless_comment_fixture()
      assert LemmalessComments.get_lemmaless_comment!(lemmaless_comment.id) == lemmaless_comment
    end

    test "create_lemmaless_comment/1 with valid data creates a lemmaless_comment" do
      valid_attrs = %{
        attributes: %{},
        canonical_commentary_id: canonical_commentary_fixture().id,
        content: "some content",
        urn: CTS.URN.parse("urn:cts:greekLit:test.test001.ajmc")
      }

      assert {:ok, %LemmalessComment{} = lemmaless_comment} =
               LemmalessComments.create_lemmaless_comment(valid_attrs)

      assert lemmaless_comment.attributes == %{}
      assert lemmaless_comment.content == "some content"
      assert lemmaless_comment.urn == CTS.URN.parse("urn:cts:greekLit:test.test001.ajmc")
    end

    test "create_lemmaless_comment/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               LemmalessComments.create_lemmaless_comment(@invalid_attrs)
    end

    test "update_lemmaless_comment/2 with valid data updates the lemmaless_comment" do
      lemmaless_comment = lemmaless_comment_fixture()

      update_attrs = %{
        attributes: %{},
        content: "some updated content",
        urn: CTS.URN.parse("urn:cts:greekLit:test.test001.ajmc")
      }

      assert {:ok, %LemmalessComment{} = lemmaless_comment} =
               LemmalessComments.update_lemmaless_comment(lemmaless_comment, update_attrs)

      assert lemmaless_comment.attributes == %{}
      assert lemmaless_comment.content == "some updated content"
      assert lemmaless_comment.urn == CTS.URN.parse("urn:cts:greekLit:test.test001.ajmc")
    end

    test "update_lemmaless_comment/2 with invalid data returns error changeset" do
      lemmaless_comment = lemmaless_comment_fixture()

      assert {:error, %Ecto.Changeset{}} =
               LemmalessComments.update_lemmaless_comment(lemmaless_comment, @invalid_attrs)

      assert lemmaless_comment == LemmalessComments.get_lemmaless_comment!(lemmaless_comment.id)
    end

    test "delete_lemmaless_comment/1 deletes the lemmaless_comment" do
      lemmaless_comment = lemmaless_comment_fixture()

      assert {:ok, %LemmalessComment{}} =
               LemmalessComments.delete_lemmaless_comment(lemmaless_comment)

      assert_raise Ecto.NoResultsError, fn ->
        LemmalessComments.get_lemmaless_comment!(lemmaless_comment.id)
      end
    end

    test "change_lemmaless_comment/1 returns a lemmaless_comment changeset" do
      lemmaless_comment = lemmaless_comment_fixture()
      assert %Ecto.Changeset{} = LemmalessComments.change_lemmaless_comment(lemmaless_comment)
    end
  end
end
