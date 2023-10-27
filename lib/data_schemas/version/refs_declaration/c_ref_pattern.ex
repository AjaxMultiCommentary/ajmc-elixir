defmodule DataSchemas.Version.RefsDeclaration.CRefPattern do
  import DataSchema, only: [data_schema: 1]

  @data_accessor DataSchemas.XPathAccessor

  @tei_ref_regex ~r/\[@n='\$\d+'\]/
  @tei_xpath_regex ~r/xpath\((?<path>.*)\)/

  def extract_xpath_string(s) do
    m = Regex.named_captures(@tei_xpath_regex, to_string(s)) || %{}

    {:ok, Map.get(m, "path")}
  end

  def extract_and_clean_xpath_string(s) do
    path =
      Regex.named_captures(@tei_xpath_regex, s)
      |> Map.get("path")
      |> String.replace(@tei_ref_regex, "")

    {:ok, path}
  end

  data_schema(
    field: {:description, "./p/text()", &{:ok, to_string(&1)}},
    field: {:match_pattern, "./@matchPattern", &{:ok, to_string(&1)}},
    field: {:replacement_pattern, "./@replacementPattern", &__MODULE__.extract_xpath_string/1},
    field:
      {:reference_path, "./@replacementPattern", &__MODULE__.extract_and_clean_xpath_string/1}
  )
end
