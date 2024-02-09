defmodule TextServerWeb.CommentaryJSON do
  alias TextServer.Commentaries.CanonicalCommentary

  def index(%{commentaries: commentaries}) do
    %{data: for(commentary <- commentaries, do: data(commentary))}
  end

  @doc """
  Renders a single commentary.
  """
  def show(%{commentary: commentary}) do
    %{data: data(commentary)}
  end

  defp data(%CanonicalCommentary{} = commentary) do
    %{
      id: commentary.id,
      creators:
        Enum.map(commentary.creators, &Map.take(&1, [:creator_type, :first_name, :last_name])),
      filename: commentary.filename,
      languages: commentary.languages,
      metadata: commentary.metadata,
      pid: commentary.pid,
      publication_date: commentary.publication_date,
      public_domain_year: commentary.public_domain_year,
      source_url: commentary.source_url,
      title: commentary.title,
      urn: to_string(commentary.urn),
      wikidata_qid: commentary.wikidata_qid
    }
  end
end
