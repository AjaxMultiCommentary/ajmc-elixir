defmodule TextServer.CommentariesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TextServer.Commentaries` context.
  """

  alias TextServer.CommentaryCreatorsFixtures

  def unique_filename, do: "filename#{System.unique_integer([:positive])}"
  def unique_pid, do: "pid#{System.unique_integer([:positive])}"
  def unique_title, do: "pid#{System.unique_integer([:positive])}"

  @doc """
  Generate a canonical_commentary.
  """
  def canonical_commentary_fixture(attrs \\ %{}) do
    {:ok, canonical_commentary} =
      attrs
      |> Enum.into(%{
        creators: [CommentaryCreatorsFixtures.creator_fixture()],
        languages: ["grc", "ita"],
        filename: unique_filename(),
        title: unique_title(),
        pid: unique_pid(),
        publication_date: 1980
      })
      |> TextServer.Commentaries.create_canonical_commentary()

    canonical_commentary
  end
end
