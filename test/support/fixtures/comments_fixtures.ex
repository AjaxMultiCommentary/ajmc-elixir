defmodule TextServer.CommentsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TextServer.Comments` context.
  """

  @doc """
  Generate a comment.
  """
  def comment_fixture(attrs \\ %{}) do
    {:ok, comment} =
      attrs
      |> Enum.into(%{
        attributes: %{},
        content: "some content",
        lemma: "some lemma",
        start_offset: 0,
        end_offset: 5
      })
      |> TextServer.Comments.create_comment()

    comment
  end
end
