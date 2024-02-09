defmodule TextServerWeb.CommentController do
  use TextServerWeb, :controller

  alias TextServer.Commentaries
  alias TextServer.Commentaries.CanonicalCommentary

  alias TextServer.Comments
  alias TextServer.LemmalessComments

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

  def glosses(conn, params) do
    params =
      params
      |> Map.update("start", 0, fn s -> String.to_integer(s) end)
      |> Map.update("end", 2_000_000, fn s -> String.to_integer(s) end)

    comments =
      Comments.search_comments(
        "STUB --- THIS ROUTE SHOULD ONLY BE AVAILABLE FOR LOGGED-IN USERS",
        params
      )

    comments =
      if is_nil(params["lemma"]) do
        comments ++
          LemmalessComments.list_lemmaless_comments_for_lines(
            "STUB --- THIS ROUTE SHOULD ONLY BE AVAILABLE FOR LOGGED-IN USERS",
            params["start"],
            params["end"]
          )
      else
        comments
      end

    render(conn, :index, comments: comments)
  end

  def lemmas(conn, %{"commentary_urn" => commentary_urn}) do
    case CanonicalCommentary.full_urn(commentary_urn) do
      {:ok, urn} ->
        commentary =
          Commentaries.get_canonical_commentary_by(%{urn: urn}, [
            :comments
          ])

        lemmas =
          commentary.comments
          |> Enum.sort_by(fn comment ->
            {comment.urn.citations |> List.first() |> String.to_integer(),
             Map.get(comment, :start_offset, 0)}
          end)
          |> Enum.map(fn c ->
            %{lemma: c.lemma, urn: to_string(c.urn)}
          end)

        json(conn, %{data: lemmas})

      {:error, reason} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: reason})
    end
  end
end
