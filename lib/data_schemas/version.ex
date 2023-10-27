defmodule DataSchemas.Version do
  import DataSchema, only: [data_schema: 1]

  @data_accessor DataSchemas.PostgresXPathAccessor
  data_schema(has_one: {:body, "/tei:TEI/tei:text/tei:body", DataSchemas.Version.Body})
end

defmodule DataSchemas.Version.Body do
  import DataSchema, only: [data_schema: 1]

  @data_accessor DataSchemas.XPathAccessor
  data_schema(
    has_many: {:notes, "//note", DataSchemas.Version.Body.Note},
    has_many: {:speakers, "./sp", DataSchemas.Version.Body.Speaker}
  )
end

defmodule DataSchemas.Version.Body.Note do
  import DataSchema, only: [data_schema: 1]

  @data_accessor DataSchemas.XPathAccessor
  data_schema(
    field: {:n, "./@n", &{:ok, &1}},
    field: {:text, "./text()", &{:ok, &1}}
  )
end

defmodule DataSchemas.Version.Body.Speaker do
  import DataSchema, only: [data_schema: 1]

  @data_accessor DataSchemas.XPathAccessor
  data_schema(
    field: {:name, "./speaker/text()", &{:ok, &1}},
    has_many: {:lines, "./l", DataSchemas.Version.Body.Speaker.Line}
  )
end

defmodule DataSchemas.Version.Body.Speaker.Line do
  import DataSchema, only: [data_schema: 1]

  @data_accessor DataSchemas.XPathAccessor
  data_schema(
    field: {:n, "./@n", &{:ok, &1}},
    field: {:text, "./text()", &{:ok, &1}}
  )
end
