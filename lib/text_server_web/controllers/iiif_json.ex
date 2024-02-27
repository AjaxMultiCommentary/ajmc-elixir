defmodule TextServerWeb.IiifJSON do
  def info(%{iiif_id: iiif_id, width: width, height: height}) do
    %{
      :"@context" => "http://iiif.io/api/image/3/context.json",
      :id => iiif_id,
      :type => "ImageService3",
      :protocol => "http://iiif.io/api/image",
      :profile => "level0",
      :width => width,
      :height => height,
      :preferredFormats => ["png"],
      :sizes => [%{width: width, height: height}],
      :tiles => [%{width: width, height: height, scaleFactors: [1]}]
    }
  end
end
