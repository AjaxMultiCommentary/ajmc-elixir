defmodule DataSchemas.Work.CTSDocument.VersionFragment do
  import DataSchema, only: [data_schema: 1]

  @data_accessor DataSchemas.XPathAccessor
  data_schema(
    field: {:description, "./ti:description/text()", &{:ok, String.trim(to_string(&1))}},
    field: {:label, "./ti:label/text()", &{:ok, String.trim(to_string(&1))}},
    field: {:language, "./@xml:lang", &{:ok, to_string(&1)}},
    field: {:urn, "./@urn", &{:ok, to_string(&1)}}
  )
end
