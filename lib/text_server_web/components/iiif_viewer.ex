defmodule TextServerWeb.Components.IiifViewer do
  use TextServerWeb, :live_component

  attr :comment, TextServer.TextElements.TextElement

  def render(assigns) do
    ~H"""
    <div
      id={"comment-#{@comment.id}"}
      class="openseadragon-iiif-viewer"
      phx-hook="IIIFHook"
      data-tiles={tiles(@comment)}
      data-comment={Jason.encode!(@comment.attributes)}
    />
    """
  end

  defp tiles(comment) do
    Map.get(comment, :attributes)
    |> Map.get("image_paths")
    |> Enum.dedup()
    |> Enum.map(fn p ->
      %{
        type: "image",
        url: Application.get_env(:text_server, :iiif_root_url) <> p,
        crossOriginPolicy: "Anonymous",
        ajaxWithCredentials: false,
        imagePath: p
      }
    end)
    |> Jason.encode!()
  end
end
