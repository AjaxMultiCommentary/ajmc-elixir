defmodule TextServerWeb.ReadLive.Reader.Passage do
  use TextServerWeb, :live_component

  attr :lemmas, :list, default: []
  attr :passage, :string, required: true

  def render(assigns) do
    ~H"""
    <div id="reader-passage" phx-hook="TEIHook" data-lemmas={Jason.encode!(@lemmas)}>
      <%= raw(@passage) %>
    </div>
    """
  end
end
