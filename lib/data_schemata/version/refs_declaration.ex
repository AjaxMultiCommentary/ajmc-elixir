defmodule DataSchemata.Version.RefsDeclaration do
  import DataSchema, only: [data_schema: 1]

  @data_accessor DataSchemata.XPathAccessor
  data_schema(
    has_many:
      {:c_ref_patterns, "/refsDecl/cRefPattern", DataSchemata.Version.RefsDeclaration.CRefPattern,
       optional?: true},
    list_of: {:unit_labels, "/refsDecl/refState/@unit", &{:ok, to_string(&1)}, optional?: true}
  )
end
