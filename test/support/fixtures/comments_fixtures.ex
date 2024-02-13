defmodule TextServer.CommentsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TextServer.Comments` context.
  """

  alias TextServer.CommentariesFixtures

  @doc """
  Generate a comment.
  """
  def comment_fixture(attrs \\ %{}) do
    commentary = CommentariesFixtures.canonical_commentary_fixture()

    {:ok, comment} =
      attrs
      |> Enum.into(%{
        attributes: %{},
        canonical_commentary_id: commentary.id,
        content: "some content",
        lemma: "some lemma",
        start_offset: 0,
        end_offset: 5,
        urn: "#{commentary.urn}:1@abcdef"
      })
      |> TextServer.Comments.create_comment()

    comment
  end
end
