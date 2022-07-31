defmodule TextServerWeb.ImageLive.ImageComponents do
  use TextServerWeb, :component

  def image_with_attribution(%{image: image} = assigns) do
    ~H"""
    <div class="h-64 w-64 relative">
      <div
        class="absolute inset-0 bg-cover bg-center z-0"
        style={"background-image: url('#{image.image_url}')"}
      >
      </div>
      <div class="h-7 opacity-90 bg-gray-300 absolute inset-x-0 bottom-0 z-10 flex justify-center items-end text-lg text-gray-700 font-semibold">
        Photo by <a href={image.attribution_url}><%= image.attribution_name %></a> on
        <a href={image.attribution_source_url}><%= image.attribution_source %>.</a>
      </div>
    </div>
    """
  end
end
