defmodule DataSchemas.Version do
  import DataSchema, only: [data_schema: 1]

  @derive {Jason.Encoder, only: [:body]}

  @data_accessor DataSchemas.PostgresXPathAccessor
  data_schema(has_one: {:body, "/tei:TEI/tei:text/tei:body", DataSchemas.Version.Body})
end

defmodule DataSchemas.Version.Body do
  import DataSchema, only: [data_schema: 1]

  @derive {Jason.Encoder, only: [:lines, :notes, :speakers]}

  @data_accessor DataSchemas.XPathAccessor
  data_schema(
    has_many: {:lines, "//l", DataSchemas.Version.Body.Line},
    has_many: {:notes, "//note", DataSchemas.Version.Body.Note},
    has_many: {:speakers, "//sp", DataSchemas.Version.Body.Speaker}
  )
end

defmodule DataSchemas.Version.SaxEventHandler do
  require Logger
  @behaviour Saxy.Handler

  def handle_event(:start_document, _prolog, state) do
    {:ok, state}
  end

  def handle_event(:end_document, _data, state) do
    {:ok, state}
  end

  def handle_event(:start_element, {name, attributes}, state) do
    {:ok, handle_element(name, attributes, state)}
  end

  def handle_event(:end_element, _name, %{element_stack: []} = state), do: {:ok, state}

  def handle_event(:end_element, name, state) do
    [curr | rest] = state.element_stack

    if name == curr.name do
      element_stack = [Map.put(curr, :end_offset, String.length(state.text)) | rest]
      {:ok, %{state | element_stack: element_stack}}
    else
      {:ok, state}
    end
  end

  def handle_event(:characters, chars, %{text: ""} = state) do
    {:ok, %{state | text: state.text <> String.trim(chars)}}
  end

  def handle_event(:characters, chars, state) do
    {:ok, %{state | text: state.text <> " " <> String.trim(chars)}}
  end

  defp handle_element("add", attributes, state) do
    element_stack = [
      %{name: "add", start_offset: String.length(state.text), attributes: attributes}
      | state.element_stack
    ]

    %{state | element_stack: element_stack}
  end

  defp handle_element("l", _attributes, state) do
    state
  end

  defp handle_element("del", attributes, state) do
    element_stack = [
      %{name: "del", start_offset: String.length(state.text), attributes: attributes}
      | state.element_stack
    ]

    %{state | element_stack: element_stack}
  end

  defp handle_element(name, attributes, state) do
    Logger.warning("Unknown element #{name} with attributes #{inspect(attributes)}.")
    state
  end
end

defmodule DataSchemas.Version.Body.Line do
  import DataSchema, only: [data_schema: 1]

  @derive {Jason.Encoder, only: [:elements, :n, :raw, :text]}

  @data_accessor DataSchemas.XPathAccessor
  data_schema(
    field:
      {:elements, ".",
       fn xml ->
         {:ok, state} =
           Saxy.parse_string(xml, DataSchemas.Version.SaxEventHandler, %{
             element_stack: [],
             text: ""
           })

         {:ok, state.element_stack}
       end},
    field: {:n, "./@n", &{:ok, &1}},
    field: {:raw, ".", &{:ok, &1}},
    field:
      {:text, ".",
       fn xml ->
         {:ok, state} =
           Saxy.parse_string(xml, DataSchemas.Version.SaxEventHandler, %{
             element_stack: [],
             text: ""
           })

         {:ok, String.trim(state.text)}
       end}
  )
end

defmodule DataSchemas.Version.Body.Note do
  import DataSchema, only: [data_schema: 1]

  @derive {Jason.Encoder, only: [:n, :text]}

  @data_accessor DataSchemas.XPathAccessor
  data_schema(
    field: {:n, "./@n", &{:ok, &1}},
    field: {:text, "./text()", &{:ok, &1}}
  )
end

defmodule DataSchemas.Version.Body.Speaker do
  import DataSchema, only: [data_schema: 1]

  @moduledoc """
  DataSchema for `speaker`s in TEI XML. Should we
  unwrap the `has_many` below and instead treat it
  as an aggregate that collects all of the @n attributes
  for lines under a given speaker in the XML?
  """

  @derive {Jason.Encoder, only: [:lines, :name]}

  @data_accessor DataSchemas.XPathAccessor
  data_schema(
    field: {:name, "./speaker/text()", &{:ok, &1}},
    list_of: {:lines, "./l/@n", &{:ok, to_string(&1)}}
  )
end
