defmodule TextServer.LemmalessCommentsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TextServer.LemmalessComments` context.
  """

  alias TextServer.CommentariesFixtures

  @doc """
  Generate a lemmaless_comment.
  """
  def lemmaless_comment_fixture(attrs \\ %{}) do
    canonical_commentary = CommentariesFixtures.canonical_commentary_fixture()

    {:ok, lemmaless_comment} =
      attrs
      |> Enum.into(%{
        attributes: %{},
        canonical_commentary_id: canonical_commentary.id,
        content: "some content",
        urn: CTS.URN.parse("urn:cts:greekLit:sample001.example001.ajmc")
      })
      |> TextServer.LemmalessComments.create_lemmaless_comment()

    lemmaless_comment
  end
end
