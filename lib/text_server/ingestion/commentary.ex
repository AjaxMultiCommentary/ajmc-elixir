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

  defp ingest_lemma(urn, element_type, %{"anchor_target" => anchor_target} = lemma)
       when not is_nil(anchor_target) do
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

  defp ingest_lemma(_urn, _element_type, _lemma), do: nil

  defp dangling_line_anchor_regex, do: ~r/\d{0,4}\s{0,2}$/

  defp passage_regex,
    do:
      ~r/tei-l@n=(?<first_line_n>\d+)\[(?<first_line_offset>\d+)\]:tei-l@n=(?<last_line_n>\d+)\[(?<last_line_offset>\d+)\]/

  defp prepare_lemmas_from_canonical_json(path) do
    s = File.read!(path)
    json = Jason.decode!(s)

    children = json |> Map.get("children")

    lemmas =
      children
      |> Map.get("lemmas")
      |> Enum.filter(fn l ->
        case Map.get(l, "label") do
          "scope-anchor" -> true
          "word-anchor" -> true
          _ -> false
        end
      end)

    pages = children |> Map.get("pages")

    words =
      children
      |> Map.get("words")
      |> Enum.with_index(fn el, index -> Map.put(el, :index, index) end)

    regions = children |> Map.get("regions")

    # TODO: start by chunking by scope_anchor, then split on the lemmas (if they exist)
    # within a given scope
    regions
    |> Enum.drop_while(&(Map.get(&1, "region_type") != "primary_text"))
    |> Enum.chunk_by(&Map.get(&1, "region_type"))

    commentaries = regions |> Enum.filter(&(Map.get(&1, "region_type") == "commentary"))

    lemmas
    |> Enum.chunk_every(2, 1)
    |> Enum.map(&prepare_lemma(commentaries, pages, words, &1))
  end

  defp prepare_lemma(commentaries, pages, words, [lemma]) do
    [lemma_first | [lemma_last]] = Map.get(lemma, "word_range")
    lemma_range = lemma_first..lemma_last
    lemma_words = WordRange.get_words_for_range(words, lemma_range)
    lemma_text = lemma_words |> Enum.map(&Map.get(&1, "text")) |> Enum.join(" ")

    commentaries =
      WordRange.filter_containers_within_range(commentaries, lemma_range)

    commentary_ranges = Enum.map(commentaries, &Map.get(&1, "word_range")) |> List.flatten()
    page_range = List.first(commentary_ranges)..List.last(commentary_ranges)
    pages = WordRange.filter_containers_within_range(pages, page_range)

    glossa_words =
      commentaries
      |> Enum.flat_map(&WordRange.get_words_for_range(words, Map.get(&1, "word_range")))
      |> Enum.drop_while(fn w -> !Enum.member?(lemma_words, w) end)
      |> Enum.chunk_by(fn w ->
        index = Map.get(w, :index)

        Enum.find(commentaries, fn c ->
          [cf, cl] = Map.get(c, "word_range")

          index in cf..cl
        end)
      end)

    glossa_overlays = calculate_overlays(pages, glossa_words)

    glossa =
      glossa_words
      |> List.flatten()
      |> Enum.map(&Map.get(&1, "text"))
      |> Enum.join(" ")
      |> String.trim()

    lemma_transcript =
      if is_nil(Map.get(lemma, "transcript")) do
        lemma_words |> Enum.map(&Map.get(&1, "text")) |> Enum.join(" ")
      else
        Map.get(lemma, "transcript")
      end

    Map.merge(lemma, %{
      "content" => glossa,
      "lemma" => lemma_transcript,
      "overlays" => glossa_overlays,
      "words" => lemma_words,
      "commentary_word_ranges" => commentaries |> Enum.map(&Map.get(&1, "word_range")),
      "image_paths" =>
        pages
        |> Enum.map(fn p ->
          page_id = Map.get(p, "id")
          commentary_id = page_id |> String.split("_") |> List.first()

          "#{commentary_id}/#{page_id}/full/max/0/default.png"
        end)
    })
  end

  defp prepare_lemma(commentaries, pages, words, [lemma, next_lemma]) do
    [lemma_first | [lemma_last]] = Map.get(lemma, "word_range")
    lemma_range = lemma_first..lemma_last
    lemma_words = WordRange.get_words_for_range(words, lemma_range)
    lemma_text = lemma_words |> Enum.map(&Map.get(&1, "text")) |> Enum.join(" ")

    [next_lemma_first | [next_lemma_last]] = Map.get(next_lemma, "word_range")
    next_lemma_range = next_lemma_first..next_lemma_last
    next_lemma_words = WordRange.get_words_for_range(words, next_lemma_range)
    next_lemma_text = next_lemma_words |> Enum.map(&Map.get(&1, "text")) |> Enum.join(" ")

    commentaries =
      WordRange.filter_containers_within_range(
        commentaries,
        lemma_first..next_lemma_first
      )

    pages =
      WordRange.filter_containers_within_range(
        pages,
        lemma_first..next_lemma_first
      )

    glossa_words =
      commentaries
      |> Enum.flat_map(fn c ->
        WordRange.get_words_for_range(words, Map.get(c, "word_range"))
      end)
      |> Enum.drop_while(fn w -> !Enum.member?(lemma_words, w) end)
      |> Enum.take_while(fn w -> !Enum.member?(next_lemma_words, w) end)
      |> Enum.chunk_by(fn w ->
        index = Map.get(w, :index)

        Enum.find(commentaries, fn c ->
          [cf, cl] = Map.get(c, "word_range")

          index in cf..cl
        end)
      end)

    glossa_overlays = calculate_overlays(pages, glossa_words)

    glossa =
      glossa_words
      |> List.flatten()
      |> Enum.map(&Map.get(&1, "text"))
      |> Enum.join(" ")
      |> String.trim()

    lemma_transcript =
      if is_nil(Map.get(lemma, "transcript")) do
        lemma_words |> Enum.map(&Map.get(&1, "text")) |> Enum.join(" ")
      else
        Map.get(lemma, "transcript")
      end

    Map.merge(lemma, %{
      "content" => glossa,
      "lemma" => lemma_transcript,
      "words" => lemma_words,
      "commentary_word_ranges" => commentaries |> Enum.map(&Map.get(&1, "word_range")),
      "overlays" => glossa_overlays,
      "image_paths" =>
        pages
        |> Enum.map(fn p ->
          page_id = Map.get(p, "id")
          commentary_id = page_id |> String.split("_") |> List.first()

          "#{commentary_id}/#{page_id}/full/max/0/default.png"
        end)
    })
  end

  defp calculate_overlays(pages, words_grouped_by_region) do
    words_grouped_by_region
    |> Enum.flat_map(fn words ->
      words
      |> Enum.chunk_by(fn word ->
        index = Map.get(word, :index)

        Enum.find(pages, fn page ->
          [p_f, p_l] = Map.get(page, "word_range")

          index in p_f..p_l
        end)
      end)
    end)
    |> Enum.map(fn words ->
      word = List.first(words)

      index = Map.get(word, :index)

      page_id =
        Enum.find(pages, fn page ->
          [p_f, p_l] = Map.get(page, "word_range")

          index in p_f..p_l
        end)
        |> Map.get("id")

      bboxes = words |> Enum.map(&Map.get(&1, "bbox"))

      xs =
        bboxes
        |> Enum.flat_map(fn bbox_pair ->
          bbox_pair |> Enum.map(&Enum.at(&1, 0))
        end)

      ys =
        bboxes
        |> Enum.flat_map(fn bbox_pair ->
          bbox_pair |> Enum.map(&Enum.at(&1, 1))
        end)

      left_most = Enum.min(xs)
      right_most = Enum.max(xs)
      top_most = Enum.min(ys)
      bottom_most = Enum.max(ys)

      %{
        px: left_most,
        py: top_most,
        width: right_most - left_most,
        height: bottom_most - top_most,
        page_id: page_id
      }
    end)
  end
end
