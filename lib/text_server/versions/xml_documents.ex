defmodule TextServer.Versions.XmlDocuments do
  import Ecto.Query, warn: false

  alias TextServer.Repo
  alias DataSchemata.Version.EncodingDescription
  alias DataSchemata.Version.RefsDeclaration
  alias TextServer.Versions.XmlDocuments.XmlDocument

  def get_passage(%XmlDocument{} = document, passage_ref) do
    {:ok, refs_decl} = get_refs_decl(document)
    get_passage(document, refs_decl, passage_ref)
  end

  def get_passage(%XmlDocument{} = document, %RefsDeclaration{} = _refs_decl, :all) do
    {:ok, get_xpath_result(document, "//tei:text")}
  end

  def get_passage(%XmlDocument{} = document, %RefsDeclaration{} = refs_decl, passage_ref) do
    c_ref_pattern_idx = max(length(refs_decl.unit_labels) - 2, 1)
    c_ref_pattern = Enum.at(refs_decl.c_ref_patterns, c_ref_pattern_idx)
    replacement_pattern = Map.get(c_ref_pattern, :replacement_pattern)

    replacements =
      Tuple.to_list(passage_ref)
      |> Enum.with_index(1)
      |> Map.new(fn {k, idx} -> {"$#{idx}", k} end)

    lookup_pattern =
      replacement_pattern
      |> String.replace(Map.keys(replacements), fn match ->
        Map.get(replacements, match)
      end)

    {:ok, get_xpath_result(document, lookup_pattern)}
  end

  def get_refs_decl(%XmlDocument{} = document) do
    refs_decl = get_xpath_result(document, refs_decl_xpath())

    {:ok, encoding_desc} =
      DataSchema.to_struct(List.first(refs_decl), EncodingDescription)

    base_refs =
      encoding_desc.refs_declarations |> Enum.find(fn ref -> length(ref.c_ref_patterns) > 0 end)

    unit_labels =
      encoding_desc.refs_declarations
      |> Enum.find(%{}, fn ref -> length(ref.unit_labels) > 0 end)
      |> Map.get(:unit_labels, [])

    {:ok, Map.put(base_refs, :unit_labels, unit_labels)}
  end

  def get_table_of_contents(%XmlDocument{} = document) do
    {:ok, refs_decl} = get_refs_decl(document)
    get_table_of_contents(document, refs_decl)
  end

  def get_table_of_contents(%XmlDocument{} = document, %RefsDeclaration{} = refs_decl) do
    paths = Enum.map(refs_decl.c_ref_patterns, & &1.reference_path)

    refs =
      paths
      |> Enum.map(fn path ->
        get_xpath_result(document, path <> "/@n")
      end)
      |> TextServer.Versions.XmlDocuments.TableOfContents.collect_citations()

    {:ok, refs}
  end

  @doc """
  Queries the given version using PostgreSQL's built-in
  xpath support.
  """
  def get_xpath_result(%XmlDocument{} = document, path) do
    XmlDocument
    |> where([d], d.id == ^document.id)
    |> select(
      fragment(
        """
        xpath(
          ?,
          document,
          ARRAY[ARRAY['tei', 'http://www.tei-c.org/ns/1.0']]
        )::text[]
        """,
        ^path
      )
    )
    |> Repo.one()
  end

  defp refs_decl_xpath do
    "/tei:TEI/tei:teiHeader/tei:encodingDesc"
  end
end
