defmodule DataSchemas.Version.EncodingDescription do
  import DataSchema, only: [data_schema: 1]

  @data_accessor DataSchemas.XPathAccessor

  data_schema(
    has_many: {:refs_declarations, "/encodingDesc/refsDecl", DataSchemas.Version.RefsDeclaration}
  )
end
