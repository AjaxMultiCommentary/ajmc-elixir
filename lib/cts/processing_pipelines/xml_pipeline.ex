defmodule CTS.ProcessingPipelines.XmlPipeline do
  alias TextServer.Languages
  alias TextServer.TextGroups.TextGroup
  alias TextServer.Versions
  alias TextServer.Works
  alias TextServer.Works.Work

  def run_works do
    Works.list_works() |> Enum.each(&create_versions_of_work/1)
  end

  def create_commentary(work, version_data) do
    create_version(work, version_data, :commentary)
  end

  def create_edition(work, version_data) do
    create_version(work, version_data, :edition)
  end

  def create_translation(work, version_data) do
    create_version(work, version_data, :translation)
  end

  def create_version(work, version_data, version_type) do
    urn = Map.get(version_data, :urn) |> CTS.URN.parse()

    case get_version_file(urn) do
      :enoent ->
        {:error, "Could not find file for urn #{urn}."}

      file ->
        xml_raw = File.read!(file)
        md5 = :crypto.hash(:md5, xml_raw) |> Base.encode16(case: :lower)
        {:ok, language} = Languages.find_or_create_language_by_iso_code(version_data.language)

        unless is_nil(language) do
          {:ok, version} =
            Map.take(version_data, [:description, :label])
            |> Map.merge(%{
              filename: file,
              filemd5hash: md5,
              language_id: language.id,
              urn: urn,
              version_type: version_type,
              work_id: work.id
            })
            |> Versions.find_or_create_version()

          Versions.create_xml_document!(version, %{document: xml_raw})
        end
    end
  end

  def create_versions_of_work(%Work{} = work) do
    case get_work_cts_data(work) do
      {:ok, work_cts_data} ->
        Map.get(work_cts_data, :commentaries) |> Enum.each(&create_commentary(work, &1))
        Map.get(work_cts_data, :editions) |> Enum.each(&create_edition(work, &1))
        Map.get(work_cts_data, :translations) |> Enum.each(&create_translation(work, &1))

      {:error, reason} ->
        IO.puts(reason)
    end
  end

  def get_version_file(urn) do
    path = CTS.base_cts_dir() <> "/" <> get_work_dir(urn) <> "/#{urn.work_component}.xml"

    if File.exists?(path) do
      path
    else
      :enoent
    end
  end

  def get_work_cts_data(%Work{} = work) do
    case get_work_cts_file(work) do
      :enoent ->
        {:error, "Could not find file for #{work.english_title}."}

      cts_file ->
        cts_data_raw = File.read!(cts_file)
        DataSchema.to_struct(cts_data_raw, DataSchemas.Work.CTSDocument)
    end
  end

  def get_work_cts_file(work) do
    path = CTS.base_cts_dir() <> "/#{get_work_dir(work.urn)}/__cts__.xml"

    if File.exists?(path) do
      path
    else
      :enoent
    end
  end

  def get_work_dir(%CTS.URN{} = urn) do
    "#{urn.text_group}/#{urn.work}"
  end

  def list_text_group_files(%TextGroup{} = text_group) do
    text_group_cts_file = CTS.base_cts_dir() <> "/#{text_group.urn.text_group}/__cts__.xml"

    work_cts_files =
      Path.wildcard(CTS.base_cts_dir() <> "/#{text_group.urn.text_group}/*/__cts__.xml")

    [text_group_cts_file | work_cts_files]
  end
end
