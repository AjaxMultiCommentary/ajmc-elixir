defmodule TextServerWeb.Helpers.Markdown do
  def sanitize_and_parse_markdown(md) do
    {_status, html, _msgs} =
      md
      |> HtmlSanitizeEx.markdown_html()
      |> Earmark.as_html(compact_output: true, inner_html: true)

    html
  end
end
