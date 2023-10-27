defmodule DataSchemas.PostgresXPathAccessor do
  @behaviour DataSchema.DataAccessBehaviour

  alias TextServer.Versions.XmlDocuments
  alias TextServer.Versions.XmlDocuments.XmlDocument

  @moduledoc """
  This DataSchema accessor is mainly meant to work around the limitations
  of xmerl. Specifically, xmerl cannot parse the XML declarations that
  often appear in the prologues of TEI XML documents (e.g., `<?xml-model ... ?>`).

  A shortcoming of this approach is that namespaces need to be included
  when accessing elements.

  For example, looking for `/TEI/text/body` will fail. Instead, the path
  should look like `/tei:TEI/tei:text/tei:body`.
  """

  @impl true
  def field(%XmlDocument{} = data, path) do
    XmlDocuments.get_xpath_result(data, path) |> List.first() |> to_string()
  end

  @impl true
  def list_of(data, path) do
    XmlDocuments.get_xpath_result(data, path)
  end

  @impl true
  def has_one(data, path) do
    XmlDocuments.get_xpath_result(data, path) |> List.first()
  end

  @impl true
  def has_many(data, path) do
    XmlDocuments.get_xpath_result(data, path)
  end
end
