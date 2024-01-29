defmodule TextServer.StaticPages do
  alias TextServer.StaticPages.Page

  use NimblePublisher,
    build: Page,
    from: Application.app_dir(:text_server, "priv/static_pages/**/*.md"),
    as: :pages

  # Let's also get all tags
  @tags @pages |> Enum.flat_map(& &1.tags) |> Enum.uniq() |> Enum.sort()

  # And finally export them
  def all_pages, do: @pages
  def all_tags, do: @tags
end
