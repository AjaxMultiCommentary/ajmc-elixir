defmodule TextServerWeb.CommentController do
  use TextServerWeb, :controller

  alias TextServer.Commentaries
  alias TextServer.Commentaries.CanonicalCommentary

  # alias TextServer.Comments
  # alias TextServer.LemmalessComments

  action_fallback TextServerWeb.FallbackController

  def index(conn, %{"commentary_urn" => commentary_urn}) do
    case CanonicalCommentary.full_urn(commentary_urn) do
      {:ok, urn} ->
        commentary =
          Commentaries.get_canonical_commentary_by(%{urn: urn}, [
            :comments,
            :lemmaless_comments
          ])

        comments =
          (commentary.comments ++ commentary.lemmaless_comments)
          |> Enum.sort_by(fn comment ->
            {comment.urn.citations |> List.first() |> String.to_integer(),
             Map.get(comment, :start_offset, 0)}
          end)

        render(conn, :index, comments: comments)

      {:error, reason} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: reason})
    end
  end
end
