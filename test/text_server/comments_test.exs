defmodule TextServer.CommentsTest do
  use TextServer.DataCase

  alias TextServer.Comments

  describe "comments" do
    alias TextServer.Comments.Comment

    import TextServer.CommentariesFixtures
    import TextServer.CommentsFixtures
    import TextServer.TextNodesFixtures

    @invalid_attrs %{attributes: nil, content: nil, lemma: nil}

    test "list_comments/0 returns all comments" do
      comment = comment_fixture()
      assert Comments.list_comments() == [comment]
    end

    test "get_comment!/1 returns the comment with given id" do
      comment = comment_fixture()
      assert Comments.get_comment!(comment.id) == comment
    end

    test "create_comment/1 with valid data creates a comment" do
      commentary = canonical_commentary_fixture()

      valid_attrs = %{
        attributes: %{},
        canonical_commentary_id: commentary.id,
        content: "some content",
        lemma: "some lemma",
        start_offset: 0,
        end_offset: 8,
        urn: "#{commentary.urn}:2@abcdefgh"
      }

      assert {:ok, %Comment{} = comment} = Comments.create_comment(valid_attrs)
      assert comment.attributes == %{}
      assert comment.content == "some content"
      assert comment.lemma == "some lemma"
    end

    test "create_comment/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Comments.create_comment(@invalid_attrs)
    end

    test "update_comment/2 with valid data updates the comment" do
      comment = comment_fixture()

      update_attrs = %{
        attributes: %{},
        content: "some updated content",
        lemma: "some updated lemma"
      }

      assert {:ok, %Comment{} = comment} = Comments.update_comment(comment, update_attrs)
      assert comment.attributes == %{}
      assert comment.content == "some updated content"
      assert comment.lemma == "some updated lemma"
    end

    test "update_comment/2 with invalid data returns error changeset" do
      comment = comment_fixture()
      assert {:error, %Ecto.Changeset{}} = Comments.update_comment(comment, @invalid_attrs)
      assert comment == Comments.get_comment!(comment.id)
    end

    test "delete_comment/1 deletes the comment" do
      comment = comment_fixture()
      assert {:ok, %Comment{}} = Comments.delete_comment(comment)
      assert_raise Ecto.NoResultsError, fn -> Comments.get_comment!(comment.id) end
    end

    test "change_comment/1 returns a comment changeset" do
      comment = comment_fixture()
      assert %Ecto.Changeset{} = Comments.change_comment(comment)
    end
  end
end
