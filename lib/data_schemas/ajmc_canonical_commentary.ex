defmodule DataSchemas.AjmcCanonicalCommentary do
  import DataSchema, only: [data_schema: 1]

  @data_accessor DataSchemas.DeepMapAccessor
  data_schema(
    field: {:id, "id", &{:ok, &1}},
    field: {:ocr_run_id, "ocr_run_id", &{:ok, &1}},
    has_many:
      {:commentaries, ["children", "commentaries"],
       DataSchemas.AjmcCanonicalCommentary.Commentary, optional?: true},
    has_many: {:entities, ["children", "entities"], DataSchemas.AjmcCanonicalCommentary.Entity},
    has_many:
      {:hyphenations, ["children", "hyphenations"],
       DataSchemas.AjmcCanonicalCommentary.Hyphenation},
    has_many: {:lemmas, ["children", "lemmas"], DataSchemas.AjmcCanonicalCommentary.Lemma},
    has_many: {:lines, ["children", "lines"], DataSchemas.AjmcCanonicalCommentary.Line},
    has_many: {:pages, ["children", "pages"], DataSchemas.AjmcCanonicalCommentary.Page},
    has_many: {:regions, ["children", "regions"], DataSchemas.AjmcCanonicalCommentary.Region},
    has_many: {:sections, ["children", "sections"], DataSchemas.AjmcCanonicalCommentary.Section},
    has_many:
      {:sentences, ["children", "sentences"], DataSchemas.AjmcCanonicalCommentary.Sentence},
    has_many: {:words, ["children", "words"], DataSchemas.AjmcCanonicalCommentary.Word}
  )
end

defmodule DataSchemas.AjmcCanonicalCommentary.Commentary do
  import DataSchema, only: [data_schema: 1]

  data_schema(field: {:id, "id", &{:ok, &1}})
end

defmodule DataSchemas.AjmcCanonicalCommentary.Entity do
  import DataSchema, only: [data_schema: 1]

  data_schema(
    field: {:label, "label", &{:ok, &1}, optional?: true},
    field: {:shifts, "shifts", &{:ok, &1}},
    field: {:transcript, "transcript", &{:ok, &1}, optional?: true},
    field: {:wikidata_id, "wikidata_id", &{:ok, &1}, optional?: true},
    field: {:word_range, "word_range", &{:ok, &1}}
  )
end

defmodule DataSchemas.AjmcCanonicalCommentary.Hyphenation do
  import DataSchema, only: [data_schema: 1]

  data_schema(
    field: {:shifts, "shifts", &{:ok, &1}},
    field: {:word_range, "word_range", &{:ok, &1}}
  )
end

defmodule DataSchemas.AjmcCanonicalCommentary.Lemma do
  import DataSchema, only: [data_schema: 1]

  data_schema(
    field: {:anchor_target, "anchor_target", &{:ok, Jason.decode!(&1)}, optional?: true},
    field: {:label, "label", &{:ok, &1}},
    field:
      {:selector, "anchor_target", &{:ok, Jason.decode!(&1) |> Map.get("selector")},
       optional?: true},
    field: {:shifts, "shifts", &{:ok, &1}},
    field:
      {:text_anchor, "anchor_target", &{:ok, Jason.decode!(&1) |> Map.get("textAnchor")},
       optional?: true},
    field: {:transcript, "transcript", &{:ok, &1}, optional?: true}
  )
end

defmodule DataSchemas.AjmcCanonicalCommentary.Line do
  import DataSchema, only: [data_schema: 1]

  data_schema(field: {:word_range, "word_range", &{:ok, &1}})
end

defmodule DataSchemas.AjmcCanonicalCommentary.Page do
  import DataSchema, only: [data_schema: 1]

  data_schema(
    field: {:id, "id", &{:ok, &1}},
    field: {:word_range, "word_range", &{:ok, &1}}
  )
end

defmodule DataSchemas.AjmcCanonicalCommentary.Region do
  import DataSchema, only: [data_schema: 1]

  data_schema(
    field: {:region_type, "region_type", &{:ok, &1}},
    field: {:word_range, "word_range", &{:ok, &1}}
  )
end

defmodule DataSchemas.AjmcCanonicalCommentary.Section do
  import DataSchema, only: [data_schema: 1]

  data_schema(
    field: {:id, "id", &{:ok, &1}},
    field: {:section_title, "section_title", &{:ok, &1}},
    field: {:section_types, "section_types", &{:ok, &1}},
    field: {:word_range, "word_range", &{:ok, &1}}
  )
end

defmodule DataSchemas.AjmcCanonicalCommentary.Sentence do
  import DataSchema, only: [data_schema: 1]

  data_schema(
    field: {:corrupted, "corrupted", &{:ok, &1}},
    field: {:incomplete_continuing, "incomplete_continuing", &{:ok, &1}},
    field: {:incomplete_truncated, "incomplete_truncated", &{:ok, &1}},
    field: {:shifts, "shifts", &{:ok, &1}},
    field: {:word_range, "word_range", &{:ok, &1}}
  )
end

defmodule DataSchemas.AjmcCanonicalCommentary.Word do
  import DataSchema, only: [data_schema: 1]

  data_schema(
    field: {:bbox, "bbox", &{:ok, &1}},
    field: {:text, "text", &{:ok, &1}}
  )
end
