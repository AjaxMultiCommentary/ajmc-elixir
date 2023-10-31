defmodule TextServer.CommentaryLemmasFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TextServer.CommentaryLemmas` context.
  """

  @doc """
  Generate a commentary_lemma.
  """
  def commentary_lemma_fixture(attrs \\ %{}) do
    {:ok, commentary_lemma} =
      attrs
      |> Enum.into(%{
        label: "some label",
        shifts: [1, 2],
        transcript: "some transcript",
        anchor_target: %{},
        text_anchor: "some text_anchor",
        selector: "some selector"
      })
      |> TextServer.CommentaryLemmas.create_commentary_lemma()

    commentary_lemma
  end
end
