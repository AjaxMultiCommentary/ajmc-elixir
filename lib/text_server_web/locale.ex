defmodule TextServerWeb.Locale do
  def on_mount(:set_locale, %{"locale" => locale}, _session, socket) do
    Gettext.put_locale(TextServerWeb.Gettext, locale)
    {:cont, socket}
  end

  def on_mount(:default, _params, _session, socket), do: {:cont, socket}
end
