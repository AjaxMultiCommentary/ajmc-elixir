defmodule TextServerWeb.Hooks.RestoreLocale do
  def on_mount(:default, %{"locale" => locale}, _session, socket) do
    Gettext.put_locale(TextServerWeb.Gettext, locale)
    {:cont, socket}
  end

  def on_mount(:default, _params, %{"locale" => locale}, socket) do
    Gettext.put_locale(TextServerWeb.Gettext, locale)
    {:cont, socket}
  end

  def on_mount(:default, _params, _session, socket), do: {:cont, socket}
end
