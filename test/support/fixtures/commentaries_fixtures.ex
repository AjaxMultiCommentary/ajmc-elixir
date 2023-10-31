defmodule TextServer.CommentariesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TextServer.Commentaries` context.
  """

  def unique_filename, do: "filename#{System.unique_integer([:positive])}"
  def unique_pid, do: "pid#{System.unique_integer([:positive])}"

  @doc """
  Generate a canonical_commentary.
  """
  def canonical_commentary_fixture(attrs \\ %{}) do
    {:ok, canonical_commentary} =
      attrs
      |> Enum.into(%{
        filename: unique_filename(),
        pid: unique_pid()
      })
      |> TextServer.Commentaries.create_canonical_commentary()

    canonical_commentary
  end
end
