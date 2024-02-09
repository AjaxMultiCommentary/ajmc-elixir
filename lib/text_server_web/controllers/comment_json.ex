defmodule TextServerWeb.CommentJSON do
  alias TextServer.LemmalessComments.LemmalessComment
  alias TextServer.Comments.Comment

  def index(%{comments: comments}) do
    %{data: for(comment <- comments, do: data(comment))}
  end

  @doc """
  Renders a single comment.
  """
  def show(%{comment: comment}) do
    %{data: data(comment)}
  end

  defp data(%Comment{} = comment) do
    %{
      id: comment.id,
      attributes: comment.attributes,
      content: comment.content,
      lemma: comment.lemma,
      start_offset: comment.start_offset,
      end_offset: comment.end_offset,
      urn: to_string(comment.urn)
    }
  end

  defp data(%LemmalessComment{} = comment) do
    %{
      id: comment.id,
      attributes: comment.attributes,
      content: comment.content,
      urn: to_string(comment.urn)
    }
  end
end
