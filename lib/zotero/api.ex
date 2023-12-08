defmodule Zotero.API do
  def item(item_key) do
    resp =
      base_req()
      |> Req.get!(url: "/items/#{item_key}")

    resp.body
  end

  defp base_req do
    zotero_config = Application.get_env(:text_server, Zotero.API)

    Req.new(
      base_url: zotero_config[:base_url],
      auth: {:bearer, zotero_config[:token]},
      json: true
    )
  end
end
