defmodule TextServer.Ingestion.Commentary do
  alias TextServer.ElementTypes
  alias TextServer.Ingestion.WordRange
  alias TextServer.TextElements
  alias TextServer.TextNodes

  @moduledoc """
  The main pipeline for ingesting an AjMC Canonical Commentary.
  Exposes a single function, `ingest_commentary/2`, but handles
  a lot of processing in order to apply the lemmata and glossae
  correctly.

  Private functions are documented here in lieu of @doc annotations.

  ## Private functions

  ### `passage_regex/0`

  A regular expression for parsing the cited passage from
  [Readable Ajax](https://mromanello.github.io/ReadableAjax/SophAjax_Lloyd-Jones.html).

  This regex is probably a bit verbose, but it means to be clear rather than clever.

  ### `ingest_glossa/4`

  Ingests a glossa for a lemma that does not span more than a single
  TextNode. `captures` is the map of named captures from `Regex.named_captures(passage_regex(), selector)`,
  where `selector` is derived from the `anchor_target` of a canonical JSON lemma.

  ### `ingest_multiline_glossa/4`

  Ingests a glossa for a lemma that spans more than a single TextNode. `captures` is
  the map of named captures from `Regex.named_captures(passage_regex(), selector)`,
  where `selector` is derived from the `anchor_target` of a canonical JSON lemma.

  This function will swap `first_line_n` and `last_line_n` if they are reversed
  in `selector`.

  Unlike `ingest_glossa/4`, `ingest_multiline_glossa/4` creates two
  TextElements, one for the start of the lemma containing the text `content`
  of the glossa, and another for the end of the lemma with empty `content`.

  ### `ingest_lemma/3`

  Provides the internal interface for the `ingest_[multiline_]glossa/4` functions.
  Essentially determines if a lemma spans multiple lines and calls the appropriate
  glossa ingestion function accordingly.


  ### `prepare_lemmas_from_canonical_json/1`

  Reads the AjMC canonical JSON file provided by `path`, chunking
  based on the `lemma` objects that form the canonical JSON "commentary"
  (the `region`s for which `region_type == "commentary"`).

  This function assumes that all lemmas have been identified in a given commentary.
  Making this assumption makes it possible to associate `word_range`s with
  a given `lemma` as `glossa` (the "comment") by taking all of the non-`lemma`
  words between two `lemmas` as the first `lemma`'s gloss.


  ### `prepare_lemma/3`

  Gets the words for the lemma and its associated glossa in the
  commentary.

  This function assumes that all lemmas have been identified in a given commentary.
  Making this assumption makes it possible to associate `word_range`s with
  a given `lemma` as `glossa` (the "comment") by taking all of the non-`lemma`
  words between two `lemmas` as the first `lemma`'s gloss.
  """

  @doc """
  The public entrypoint for this module. Takes a URN, e.g.,
  `"urn:cts:greekLit:tlg0011.tlg003.ajmc-lj"` and a path
  to the AjMC canonical JSON file. Returns `:ok` on success.
  """
  def ingest_commentary(urn, path) do
    {:ok, comment_element_type} = ElementTypes.find_or_create_element_type(%{name: "comment"})

    prepare_lemmas_from_canonical_json(path)
    |> Enum.each(&ingest_lemma(urn, comment_element_type, &1))

    :ok
  end

  defp ingest_glossa(urn, element_type, captures, lemma) do
    %{
      "first_line_n" => first_line_n,
      "first_line_offset" => first_line_offset,
      "last_line_offset" => last_line_offset
    } = captures

    content = Map.get(lemma, "content") |> String.replace("- ", "")
    {_, popped_content_lemma} = Map.pop(lemma, "content")
    text_node = TextNodes.get_text_node_by(%{urn: "#{urn}:#{first_line_n}"})

    {:ok, _text_element} =
      %{
        attributes: popped_content_lemma,
        content: content,
        end_offset: last_line_offset,
        element_type_id: element_type.id,
        end_text_node_id: text_node.id,
        start_offset: first_line_offset,
        start_text_node_id: text_node.id
      }
      |> TextElements.find_or_create_text_element()
  end

  defp ingest_multiline_glossa(urn, element_type, captures, lemma) do
    %{
      "first_line_n" => first_line_n,
      "first_line_offset" => first_line_offset,
      "last_line_n" => last_line_n,
      "last_line_offset" => last_line_offset
    } = captures

    content = Map.get(lemma, "content") |> String.replace("- ", "")
    {_, popped_content_lemma} = Map.pop(lemma, "content")
    # If the lemma spans multiple lines, create two comments
    # (This is essentially how Word handles block-spanning comments in their docx)
    first_n = min(String.to_integer(first_line_n), String.to_integer(last_line_n))

    [first_offset, last_offset] =
      if first_n == String.to_integer(first_line_n) do
        [first_line_offset, last_line_offset]
      else
        [last_line_offset, first_line_offset]
      end

    first_text_node = TextNodes.get_text_node_by(%{urn: "#{urn}:#{first_n}"})

    {:ok, _text_element} =
      %{
        attributes: popped_content_lemma,
        content: content,
        end_offset: String.length(first_text_node.text),
        element_type_id: element_type.id,
        end_text_node_id: first_text_node.id,
        start_offset: first_offset,
        start_text_node_id: first_text_node.id
      }
      |> TextElements.find_or_create_text_element()

    last_n = max(String.to_integer(first_line_n), String.to_integer(last_line_n))
    last_text_node = TextNodes.get_text_node_by(%{urn: "#{urn}:#{last_n}"})

    {:ok, _text_element} =
      %{
        attributes: popped_content_lemma |> Map.put(:comment_end, true),
        content: "",
        end_offset: last_offset,
        element_type_id: element_type.id,
        end_text_node_id: last_text_node.id,
        start_offset: 0,
        start_text_node_id: last_text_node.id
      }
      |> TextElements.find_or_create_text_element()
  end

  defp ingest_lemma(urn, element_type, %{"anchor_target" => anchor_target} = lemma) do
    j = Jason.decode!(anchor_target)
    selector = Map.get(j, "selector")

    with %{
           "first_line_n" => first_line_n,
           "last_line_n" => last_line_n
         } = captures <- Regex.named_captures(passage_regex(), selector) do
      if first_line_n != last_line_n do
        ingest_multiline_glossa(urn, element_type, captures, lemma)
      else
        ingest_glossa(urn, element_type, captures, lemma)
      end
    end
  end

  defp passage_regex,
    do:
      ~r/tei-l@n=(?<first_line_n>\d+)\[(?<first_line_offset>\d+)\]:tei-l@n=(?<last_line_n>\d+)\[(?<last_line_offset>\d+)\]/

  defp prepare_lemmas_from_canonical_json(path) do
    s = File.read!(path)
    json = Jason.decode!(s)

    children = json |> Map.get("children")

    lemmas =
      children |> Map.get("lemmas") |> Enum.filter(&(Map.get(&1, "label") == "word-anchor"))

    words = children |> Map.get("words")
    regions = children |> Map.get("regions")

    regions
    |> Enum.drop_while(&(Map.get(&1, "region_type") != "primary_text"))
    |> Enum.chunk_by(&Map.get(&1, "region_type"))

    commentaries = regions |> Enum.filter(&(Map.get(&1, "region_type") == "commentary"))

    lemmas
    |> Enum.chunk_every(2, 1)
    |> Enum.map(&prepare_lemma(commentaries, words, &1))
  end

  defp prepare_lemma(commentaries, words, [lemma]) do
    [lemma_first | [lemma_last]] = Map.get(lemma, "word_range")
    lemma_range = lemma_first..lemma_last
    lemma_words = WordRange.get_words_for_range(words, lemma_range)

    commentaries =
      WordRange.filter_commentaries_containing_range(commentaries, lemma_range)

    [_ | [g]] =
      commentaries
      |> Enum.map(&WordRange.get_words_for_range(words, Map.get(&1, "word_range")))
      |> Enum.join(" ")
      |> String.split(lemma_words, parts: 2, trim: true)

    glossa = (lemma_words <> g) |> String.trim()

    Map.merge(lemma, %{
      "content" => glossa,
      "words" => lemma_words,
      "commentary_word_ranges" => commentaries |> Enum.map(&Map.get(&1, "word_range"))
    })
  end

  defp prepare_lemma(commentaries, words, [lemma, next_lemma]) do
    [lemma_first | [lemma_last]] = Map.get(lemma, "word_range")
    lemma_range = lemma_first..lemma_last
    lemma_words = WordRange.get_words_for_range(words, lemma_range)

    [next_lemma_first | [next_lemma_last]] = Map.get(next_lemma, "word_range")
    next_lemma_range = next_lemma_first..next_lemma_last
    next_lemma_words = WordRange.get_words_for_range(words, next_lemma_range)

    commentaries =
      WordRange.filter_commentaries_containing_range(
        commentaries,
        lemma_first..next_lemma_first
      )

    g =
      commentaries
      |> Enum.map(&WordRange.get_words_for_range(words, Map.get(&1, "word_range")))
      |> Enum.join(" ")

    no_lemma = String.split(g, lemma_words, parts: 2, trim: true) |> List.last()

    no_next_lemma =
      String.split(no_lemma, next_lemma_words, parts: 2, trim: true) |> List.first()

    glossa = (lemma_words <> no_next_lemma) |> String.trim()

    Map.merge(lemma, %{
      "content" => glossa,
      "words" => lemma_words,
      "commentary_word_ranges" => commentaries |> Enum.map(&Map.get(&1, "word_range"))
    })
  end
end
