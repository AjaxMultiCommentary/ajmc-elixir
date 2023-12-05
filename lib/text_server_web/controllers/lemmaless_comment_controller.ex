defmodule TextServerWeb.LemmalessCommentController do
  use TextServerWeb, :controller

  alias TextServer.LemmalessComments
  alias TextServer.LemmalessComments.LemmalessComment

  action_fallback TextServerWeb.FallbackController

  def index(conn, _params) do
    lemmaless_comments = LemmalessComments.list_lemmaless_comments()
    render(conn, :index, lemmaless_comments: lemmaless_comments)
  end

  def create(conn, %{"lemmaless_comment" => lemmaless_comment_params}) do
    with {:ok, %LemmalessComment{} = lemmaless_comment} <- LemmalessComments.create_lemmaless_comment(lemmaless_comment_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/lemmaless_comments/#{lemmaless_comment}")
      |> render(:show, lemmaless_comment: lemmaless_comment)
    end
  end

  def show(conn, %{"id" => id}) do
    lemmaless_comment = LemmalessComments.get_lemmaless_comment!(id)
    render(conn, :show, lemmaless_comment: lemmaless_comment)
  end

  def update(conn, %{"id" => id, "lemmaless_comment" => lemmaless_comment_params}) do
    lemmaless_comment = LemmalessComments.get_lemmaless_comment!(id)

    with {:ok, %LemmalessComment{} = lemmaless_comment} <- LemmalessComments.update_lemmaless_comment(lemmaless_comment, lemmaless_comment_params) do
      render(conn, :show, lemmaless_comment: lemmaless_comment)
    end
  end

  def delete(conn, %{"id" => id}) do
    lemmaless_comment = LemmalessComments.get_lemmaless_comment!(id)

    with {:ok, %LemmalessComment{}} <- LemmalessComments.delete_lemmaless_comment(lemmaless_comment) do
      send_resp(conn, :no_content, "")
    end
  end
end
