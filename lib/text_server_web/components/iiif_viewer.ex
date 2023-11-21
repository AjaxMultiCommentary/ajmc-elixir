defmodule TextServerWeb.Components.IiifViewer do
  use TextServerWeb, :live_component

  attr :comments, :list, required: true
  attr :highlighted_comments, :list, required: true

  def render(assigns) do
    ~H"""
    <div
      id="openseadragon-iiif-viewer"
      class="openseadragon-iiif-viewer"
      phx-hook="IIIFHook"
      data-highlighted-comments={Jason.encode!(@highlighted_comments)}
      data-tiles={tiles(@comments)}
      data-comments={Jason.encode!(@comments |> Enum.map(&(Map.get(&1, :attributes) |> Map.put(:id, &1.id))))}
    />
    """
  end

  defp tiles(comments) do
    comments
    |> Enum.flat_map(&(Map.get(&1, :attributes) |> Map.get("image_paths")))
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
