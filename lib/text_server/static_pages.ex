defmodule TextServer.StaticPages do
  alias TextServer.StaticPages.Page

  use NimblePublisher,
    build: Page,
    from: Application.app_dir(:text_server, "priv/static_pages/**/*.md"),
    as: :pages

  def all_pages, do: @pages
end
