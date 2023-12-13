defmodule Zotero.API do
  @doc """
  Example response body:
  ```
  %{
    "data" => %{
      "ISBN" => "",
      "abstractNote" => "",
      "accessDate" => "",
      "archive" => "",
      "archiveLocation" => "",
      "callNumber" => "",
      "collections" => ["NTFEUW62"],
      "creators" => [
        %{
          "creatorType" => "author",
          "firstName" => "Friedrich Wilhelm",
          "lastName" => "Schneidewin"
        }
      ],
      "date" => "1853",
      "dateAdded" => "2021-01-04T13:38:35Z",
      "dateModified" => "2023-12-13T14:10:02Z",
      "edition" => "",
      "extra" => "Citation Key: schneidewin_sophokles_1853",
      "itemType" => "book",
      "key" => "Z3E52E63",
      "language" => "ger, grc",
      "libraryCatalog" => "",
      "numPages" => "",
      "numberOfVolumes" => "",
      "place" => "Leipzig",
      "publisher" => "Weidmann",
      "relations" => %{},
      "rights" => "",
      "series" => "",
      "seriesNumber" => "",
      "shortTitle" => "",
      "tags" => [],
      "title" => "Sophokles",
      "url" => "https://archive.org/details/sophokle1v3soph",
      "version" => 2113,
      "volume" => "1"
    },
    "key" => "Z3E52E63",
    "library" => %{
      "id" => 2605700,
      "links" => %{
        "alternate" => %{
          "href" => "https://www.zotero.org/groups/2605700",
          "type" => "text/html"
        }
      },
      "name" => "AjaxMultiCommentary",
      "type" => "group"
    },
    "links" => %{
      "alternate" => %{
        "href" => "https://www.zotero.org/groups/2605700/items/Z3E52E63",
        "type" => "text/html"
      },
      "self" => %{
        "href" => "https://api.zotero.org/groups/2605700/items/Z3E52E63",
        "type" => "application/json"
      }
    },
    "meta" => %{
      "createdByUser" => %{
        "id" => 17136,
        "links" => %{
          "alternate" => %{
            "href" => "https://www.zotero.org/matteo.romanello",
            "type" => "text/html"
          }
        },
        "name" => "Matteo Romanello",
        "username" => "matteo.romanello"
      },
      "creatorSummary" => "Schneidewin",
      "numChildren" => 0,
      "parsedDate" => "1853"
    },
    "version" => 2113
  }
  ```
  """
  def item(item_key) do
    resp =
      base_req()
      |> Req.get!(url: "/items/#{item_key}")

    resp.body
  end

  defp base_req do
    zotero_config = Application.get_env(:text_server, Zotero.API)

    Req.new(
      base_url: zotero_config[:base_url],
      auth: {:bearer, zotero_config[:token]},
      json: true
    )
  end
end
