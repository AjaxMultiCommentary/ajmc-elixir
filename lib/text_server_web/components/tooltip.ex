defmodule TextServerWeb.Components.Tooltip do
  use TextServerWeb, :component

  alias TextServerWeb.Icons

  attr :icon_class, :string
  attr :tip, :string

  def info(assigns) do
    ~H"""
    <div class="prose text-justify tooltip tooltip-neutral" data-tip={@tip}>
      <Icons.info class={@icon_class} />
    </div>
    """
  end
end
