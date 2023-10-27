defmodule DataSchemas.XPathAccessor do
  @behaviour DataSchema.DataAccessBehaviour

  import SweetXml, only: [sigil_x: 2]

  @impl true

  @doc """
  When a DataSchema asks for the current element (`"."`),
  stringify it and return it to them.

  :xmerl_xml is a callback module from the :xmerl Erlang library.

  It always prepends a header string, hence the call to `tl/1`.
  See https://github.com/kbrw/sweet_xml/pull/45
  """
  def field(data, ".") do
    :xmerl.export_simple([data], :xmerl_xml) |> tl() |> List.to_string()
  end

  def field(data, path) do
    SweetXml.xpath(data, ~x"#{path}"s)
  end

  @impl true
  def list_of(data, path) do
    SweetXml.xpath(data, ~x"#{path}"l)
  end

  @impl true
  def has_one(data, path) do
    SweetXml.xpath(data, ~x"#{path}")
  end

  @impl true
  def has_many(data, path) do
    SweetXml.xpath(data, ~x"#{path}"l)
  end
end
