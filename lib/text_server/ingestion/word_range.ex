defmodule TextServer.Ingestion.WordRange do
  @moduledoc """
  This module provides a shared interface for working with
  the `words` arrays in AjMC's canonical JSON representation.
  """

  @doc """
  Stringifies the given `range` of `words`. Also accepts a tuple of
  `[first, last]` instead of a range.

  ## Examples

      iex> get_words_for_range([%{"text" => "Ajax"}, %{"text" => "Tecmessa"}, %{"text" => "Eurysaces"}], 0..2)
      "Ajax Tecmessa"

      iex> get_words_for_range([%{"text" => "Ajax"}, %{"text" => "Tecmessa"}, %{"text" => "Eurysaces"}], [0, 2])
      "Ajax Tecmessa"
  """
  def get_words_for_range(words, %Range{} = range) do
    words
    |> Enum.slice(range)
    |> Enum.map(&Map.get(&1, "text"))
    |> Enum.join(" ")
  end

  def get_words_for_range(words, [f, l]), do: get_words_for_range(words, f..l)

  @doc """
  Returns the `commentary` objects that contain (= whose `word_range`s are not disjoint with) the
  given `range`.

  ## Examples

      iex> filter_commentaries_containing_range(
        [%{"id" => "my_commentary", "word_range" => [3, 10]}, %{"id" => "other_commentary", "word_range" => [11, 20]}],
        4..6
      )
      [%{"id" => "my_commentary", "word_range" => [3, 10]}]

      iex> filter_commentaries_containing_range(
        [%{"id" => "my_commentary", "word_range" => [3, 10]}, %{"id" => "other_commentary", "word_range" => [11, 20]}],
        30..40
      )
      []
  """
  def filter_commentaries_containing_range(commentaries, %Range{} = range) do
    commentaries
    |> Enum.filter(fn c ->
      [f | [l]] = Map.get(c, "word_range")

      !Range.disjoint?(f..l, range)
    end)
  end
end
