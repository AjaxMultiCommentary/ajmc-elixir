defmodule TextServer.CommentsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TextServer.Comments` context.
  """

  alias TextServer.CommentariesFixtures
  alias TextServer.TextNodesFixtures

  @doc """
  Generate a comment.
  """
  def comment_fixture(attrs \\ %{}) do
    commentary = CommentariesFixtures.canonical_commentary_fixture()
    start_text_node = TextNodesFixtures.text_node_fixture()
    end_text_node = TextNodesFixtures.text_node_fixture()

    {:ok, comment} =
      attrs
      |> Enum.into(%{
        attributes: %{},
        canonical_commentary_id: commentary.id,
        content: "some content",
        lemma: "some lemma",
        start_offset: 0,
        start_text_node_id: start_text_node.id,
        end_text_node_id: end_text_node.id,
        end_offset: 5
      })
      |> TextServer.Comments.create_comment()

    comment
  end
end
