defmodule TextServerWeb.CommentariesLive.Show do
  use TextServerWeb, :live_view

  alias TextServer.Commentaries
  alias TextServer.Commentaries.CanonicalCommentary

  @impl true
  def mount(%{"pid" => pid} = _params, _session, socket) do
    {:ok,
     socket
     |> assign_new(:current_user, fn -> nil end)
     |> assign(commentary: get_commentary(pid))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h4 class="text-base leading-7 base-content mb-4">
        &#10092; <.link navigate={~p"/bibliography"} class="hover:underline">Bibliography</.link>
      </h4>
      <section class="overflow-hidden bg-white shadow sm:rounded-lg">
        <div class="px-4 py-6 sm:px-6">
          <h3 class="text-base font-semibold leading-7 base-content">
            <%= @commentary.title %> (<%= @commentary.publication_date %>)
          </h3>
          <p class="mt-1 max-w-2xl text-sm leading-6 base-content">
            <%= CanonicalCommentary.creators_to_string(@commentary.creators) %>
          </p>
        </div>
        <div class="border-t border-primary">
          <dl class="divide-y divide-primary">
            <div class="px-4 py-6 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
              <dt class="text-sm font-medium base-content"><%= gettext("Public domain year") %></dt>
              <dd class="mt-1 text-sm leading-6 base-content sm:col-span-2 sm:mt-0">
                <%= @commentary.public_domain_year %>
              </dd>
            </div>
            <div class="px-4 py-6 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
              <dt class="text-sm font-medium base-content"><%= gettext("Languages") %></dt>
              <dd class="mt-1 text-sm leading-6 base-content sm:col-span-2 sm:mt-0">
                <%= @commentary.languages |> Enum.map(&iso_code_to_name/1) |> Enum.join(", ") %>
              </dd>
            </div>
            <div class="px-4 py-6 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
              <dt class="text-sm font-medium base-content">Wikidata</dt>
              <dd class="mt-1 text-sm leading-6 base-content sm:col-span-2 sm:mt-0">
                <.link href={"https://wikidata.org/wiki/#{@commentary.wikidata_qid}"}>
                  <%= @commentary.wikidata_qid %>
                </.link>
              </dd>
            </div>
          </dl>
        </div>
      </section>
    </div>
    """
  end

  defp get_commentary(pid) do
    Commentaries.get_canonical_commentary_by(%{pid: pid}) |> TextServer.Repo.preload(:creators)
  end

  defp iso_code_to_name(iso_code) do
    case iso_code do
      "de" -> gettext("German")
      "en" -> gettext("English")
      "eng" -> gettext("English")
      "fr" -> gettext("French")
      "fra" -> gettext("French")
      "fre" -> gettext("French")
      "ger" -> gettext("German")
      "grc" -> gettext("Ancient Greek")
      "it" -> gettext("Italian")
      "ita" -> gettext("Italian")
      "la" -> gettext("Latin")
      "lat" -> gettext("Latin")
      _ -> iso_code
    end
  end
end
