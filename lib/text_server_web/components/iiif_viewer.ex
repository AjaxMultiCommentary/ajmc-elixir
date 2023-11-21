defmodule TextServerWeb.IiifViewer do
  use TextServerWeb, :live_component

  attr :alt, :string, required: true
  attr :src, :string, required: true

  def render(assigns) do
    ~H"""
    <img alt={@alt} src={@src} />
    """
  end
end
