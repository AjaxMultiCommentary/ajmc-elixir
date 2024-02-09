defmodule TextServerWeb.CommentaryController do
  use TextServerWeb, :controller

  alias TextServer.Commentaries

  action_fallback TextServerWeb.FallbackController

  def show(conn, %{"urn" => urn}) do
    case full_urn(urn) do
      {:ok, urn} ->
        commentary = Commentaries.get_canonical_commentary_by(%{urn: urn}, [:creators])

        render(conn, :show, commentary: commentary)
    end
  end

  defp full_urn(urn) do
    cond do
      String.starts_with?(urn, "urn:cts:greekLit:tlg0011.tlg003.ajmc") ->
        {:ok, urn}

      String.starts_with?(urn, "greekLit:tlg0011.tlg003.ajmc") ->
        {:ok, "urn:cts:#{urn}"}

      String.starts_with?(urn, "tlg0011.tlg003.ajmc") ->
        {:ok, "urn:cts:greekLit:#{urn}"}

      String.starts_with?(urn, "ajmc") ->
        {:ok, "urn:cts:greekLit:tlg0011.tlg003.#{urn}"}

      true ->
        {:error,
         "Invalid URN `#{urn}`. URN must point to a valid resource, e.g. `urn:cts:greekLit:tlg0011.tlg003.ajmc-cam` or simply `ajmc-cam`."}
    end
  end
end
