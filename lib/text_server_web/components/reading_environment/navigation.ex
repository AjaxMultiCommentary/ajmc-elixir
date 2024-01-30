defmodule TextServerWeb.ReadingEnvironment.Navigation do
  use TextServerWeb, :component

  alias TextServerWeb.Helpers.Markdown

  @passages [
    {gettext("Prologue"), "1-133"},
    {gettext("*Parodos*"), "144-200"},
    {gettext("First episode"), "201-595"},
    {gettext("First *stasimon*"), "596-645"},
    {gettext("Second episode"), "646-692"},
    {gettext("Second *stasimon"), "693-718"},
    {gettext("Third episode"), "719-865"},
    {gettext("*Epiparodos* and *kommos*"), "866-973"},
    {gettext("Fourth episode"), "974-1184"},
    {gettext("Third *stasimon*"), "1185-1222"},
    {gettext("*Exodos*"), "1223-1420"}
  ]

  attr :current_urn, CTS.URN
  attr :version, TextServer.Versions.Version

  def nav_menu(assigns) do
    ~H"""
    <ul class="menu bg-base-200 p-0 max-w-fit [&_li>*]:rounded-none">
      <%= for passage <- passages(@version.urn.version) do %>
        <li class="text-sm">
          <.link patch={~p"/versions/#{passage.urn}"} class={[if(passage.urn == @current_urn, do: "active", else: "")]}>
            <span class="items-start">
              <%= raw(Gettext.gettext(TextServerWeb.Gettext, passage.label) |> Markdown.sanitize_and_parse_markdown()) %> (<%= passage.urn.citations
              |> List.first() %>&ndash;<%= passage.urn.citations
              |> List.last() %>)
            </span>
          </.link>
        </li>
      <% end %>
    </ul>
    """
  end

  defp passages(version_urn_fragment) do
    @passages
    |> Enum.map(fn {label, passage_segment} ->
      %{
        label: label,
        urn: CTS.URN.parse("#{urn_prefix()}.#{version_urn_fragment}:#{passage_segment}")
      }
    end)
  end

  defp urn_prefix, do: "urn:cts:greekLit:tlg0011.tlg003"
end
