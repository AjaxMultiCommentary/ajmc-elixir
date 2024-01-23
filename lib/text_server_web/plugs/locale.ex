defmodule TextServerWeb.Plugs.Locale do
  import Plug.Conn

  @locales Gettext.known_locales(TextServerWeb.Gettext)

  def init(_opts), do: nil

  def call(conn, _opts) do
    case locale_from_params(conn) || locale_from_cookies(conn) do
      nil ->
        conn

      locale ->
        Gettext.put_locale(TextServerWeb.Gettext, locale)

        conn = conn |> persist_locale(locale)
        conn
    end
  end

  defp persist_locale(conn, new_locale) do
    if conn.cookies["locale"] != new_locale do
      conn
      |> put_resp_cookie("locale", new_locale, max_age: 10 * 24 * 60 * 60)
    else
      conn
    end
    |> put_session(:locale, new_locale)
  end

  defp locale_from_params(conn) do
    conn.params["locale"] |> validate_locale()
  end

  defp locale_from_cookies(conn) do
    conn.cookies["locale"] |> validate_locale()
  end

  defp validate_locale(locale) when locale in @locales, do: locale
  defp validate_locale(_locale), do: nil
end
