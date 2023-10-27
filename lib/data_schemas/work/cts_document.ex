defmodule DataSchemas.Work.CTSDocument do
  import DataSchema, only: [data_schema: 1]

  @moduledoc """
  This module provides DataSchema facilities for parsing
  the __cts__.xml file that accompanies a work.
  """

  @data_accessor DataSchemas.XPathAccessor
  data_schema(
    field: {:language, "/ti:work/@xml:lang", &{:ok, to_string(&1)}},
    field: {:title, "/ti:work/ti:title/text()", &{:ok, String.trim(to_string(&1))}},
    field: {:urn, "/ti:work/@urn", &{:ok, to_string(&1)}},
    has_many:
      {:commentaries, "/ti:work/ti:commentary", DataSchemas.Work.CTSDocument.VersionFragment},
    has_many: {:editions, "/ti:work/ti:edition", DataSchemas.Work.CTSDocument.VersionFragment},
    has_many:
      {:translations, "/ti:work/ti:translation", DataSchemas.Work.CTSDocument.VersionFragment}
  )
end
