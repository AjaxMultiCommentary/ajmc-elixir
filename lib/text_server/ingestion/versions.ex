defmodule TextServer.Ingestion.Versions do
  alias TextServer.Collections
  alias TextServer.Languages
  alias TextServer.TextGroups
  alias TextServer.Works
  alias TextServer.Versions

  def create_versions do
    {:ok, collection} = create_collection()
    {:ok, text_group} = create_text_group(collection)
    {:ok, work} = create_work(text_group)
    language = create_language()

    for xml_file <- xml_files() do
      xml = File.read!(xml_file)

      {:ok, version} = create_version(work, language, xml)

      version = TextServer.Repo.preload(version, :xml_document)

      if is_nil(version.xml_document) do
        Versions.create_xml_document!(version, %{document: xml})
      end

      version
    end
  end

  defp create_collection do
    Collections.find_or_create_collection(%{
      repository: "https://github.com/gregorycrane/Wolf1807",
      urn: "urn:cts:greekLit",
      title: "Towards a Smart App. Crit.: Sophocles' Ajax"
    })
  end

  defp create_language do
    Languages.find_or_create_language(%{slug: "grc", title: "Greek"})
  end

  defp create_text_group(%Collections.Collection{} = collection) do
    TextGroups.find_or_create_text_group(%{
      title: "Sophocles",
      urn: "urn:cts:greekLit:tlg0011",
      collection_id: collection.id
    })
  end

  defp create_version(%Works.Work{} = work, %Languages.Language{} = language, xml) do
    Versions.find_or_create_version(%{
      description: "edited by Hugh Lloyd-Jones",
      filename: "lloyd-jones1994/tlg0011.tlg003.ajmc-lj.xml",
      filemd5hash: :crypto.hash(:md5, xml) |> Base.encode16(case: :lower),
      label: "Sophocles' <i>Ajax</i>",
      language_id: language.id,
      urn: "urn:cts:greekLit:tlg0011.tlg003.ajmc-lj",
      version_type: :edition,
      work_id: work.id
    })
  end

  defp create_work(%TextGroups.TextGroup{} = text_group) do
    Works.find_or_create_work(%{
      description: "",
      english_title: "Ajax",
      original_title: "Αἶας",
      urn: "urn:cts:greekLit:tlg0011.tlg003",
      text_group_id: text_group.id
    })
  end

  defp xml_files do
    [
      "priv/static/xml/lloyd-jones1994/tlg0011.tlg003.ajmc-lj.xml"
    ]
    |> Enum.map(&Application.app_dir(:text_server, &1))
  end
end
