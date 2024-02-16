defmodule Mix.Tasks.Test.GetSeedData do
  use Mix.Task

  alias TextServer.Comments
  alias TextServer.Commentaries
  alias TextServer.LemmalessComments
  alias TextServer.TextNodes
  alias TextServer.Versions

  def run(_args) do
    Mix.Task.run("app.start")

    urn = CTS.URN.parse("urn:cts:greekLit:tlg0011.tlg003.ajmc-lj:1-133")

    [start_location, end_location] =
      urn.passage_component |> String.split("-") |> Enum.map(&[&1])

    version = Versions.get_version_by_urn!(urn, [:language])

    text_nodes =
      TextNodes.list_text_nodes_by_version_between_locations(
        version,
        start_location,
        end_location
      )
      |> Enum.map(fn tn ->
        tn
        |> Map.take([:id, :location, :offset, :text, :version_id])
        |> Map.put(:urn, CTS.URN.to_string(tn.urn))
        |> Map.put(
          :text_elements,
          tn.text_elements
          |> Enum.map(fn te ->
            Map.take(te, [
              :attributes,
              :content,
              :end_offset,
              :start_offset,
              :canonical_commentary_id
            ])
          end)
        )
      end)

    commentaries = Commentaries.list_commentaries()

    comments =
      Comments.list_comments("TEST", 1, 133)
      |> Enum.map(fn c ->
        Map.take(c, [
          :id,
          :attributes,
          :content,
          :lemma,
          :start_offset,
          :end_offset,
          :canonical_commentary_id
        ])
        |> Map.put(:urn, CTS.URN.to_string(c.urn))
      end)

    lemmaless_comments =
      LemmalessComments.list_lemmaless_comments_for_lines("TEST", 1, 133)
      |> Enum.map(fn c ->
        Map.take(c, [
          :id,
          :attributes,
          :content,
          :canonical_commentary_id
        ])
        |> Map.put(:urn, CTS.URN.to_string(c.urn))
      end)

    dir = Application.app_dir(:text_server, "priv/seeds")

    File.write!(
      "#{dir}/test_version.json",
      Jason.encode!(
        Map.take(version, [
          :description,
          :filemd5hash,
          :filename,
          :id,
          :label,
          :source,
          :source_link,
          :urn,
          :version_type
        ])
      )
    )

    File.write!(
      "#{dir}/test_text_nodes.json",
      Jason.encode!(text_nodes)
    )

    File.write!(
      "#{dir}/test_commentaries.json",
      Jason.encode!(commentaries)
    )

    File.write!(
      "#{dir}/test_comments.json",
      Jason.encode!(comments)
    )

    File.write!(
      "#{dir}/test_lemmaless_comments.json",
      Jason.encode!(lemmaless_comments)
    )
  end
end
