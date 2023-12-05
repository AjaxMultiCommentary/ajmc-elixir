defmodule TextServer.LemmalessCommentsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TextServer.LemmalessComments` context.
  """

  @doc """
  Generate a lemmaless_comment.
  """
  def lemmaless_comment_fixture(attrs \\ %{}) do
    {:ok, lemmaless_comment} =
      attrs
      |> Enum.into(%{
        attributes: %{},
        content: "some content",
        urn: %{}
      })
      |> TextServer.LemmalessComments.create_lemmaless_comment()

    lemmaless_comment
  end
end
