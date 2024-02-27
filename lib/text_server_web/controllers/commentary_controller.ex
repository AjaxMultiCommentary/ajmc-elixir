defmodule TextServerWeb.CommentaryController do
  use TextServerWeb, :controller

  alias TextServer.Commentaries
  alias TextServer.Commentaries.CanonicalCommentary

  action_fallback TextServerWeb.FallbackController

  def index(conn, params) do
    commentaries =
      if params["public"] do
        Commentaries.list_public_commentaries()
      else
        Commentaries.list_commentaries()
      end

    conn
    |> render(:index, commentaries: commentaries)
  end

  def show(conn, %{"urn" => urn}) do
    case CanonicalCommentary.full_urn(urn) do
      {:ok, urn} ->
        commentary = Commentaries.get_canonical_commentary_by(%{urn: urn}, [:creators])

        render(conn, :show, commentary: commentary)

      {:error, reason} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: reason})
    end
  end
end
