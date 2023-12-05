defmodule TextServerWeb.LemmalessCommentJSON do
  alias TextServer.LemmalessComments.LemmalessComment

  @doc """
  Renders a list of lemmaless_comments.
  """
  def index(%{lemmaless_comments: lemmaless_comments}) do
    %{data: for(lemmaless_comment <- lemmaless_comments, do: data(lemmaless_comment))}
  end

  @doc """
  Renders a single lemmaless_comment.
  """
  def show(%{lemmaless_comment: lemmaless_comment}) do
    %{data: data(lemmaless_comment)}
  end

  defp data(%LemmalessComment{} = lemmaless_comment) do
    %{
      id: lemmaless_comment.id,
      content: lemmaless_comment.content,
      attributes: lemmaless_comment.attributes,
      urn: lemmaless_comment.urn
    }
  end
end
