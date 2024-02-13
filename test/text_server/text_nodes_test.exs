defmodule TextServer.TextNodesTest do
  use TextServer.DataCase

  alias TextServer.TextNodes
  alias TextServer.TextNodes.TextNode

  import TextServer.TextNodesFixtures

  describe "text_nodes" do
    @invalid_attrs %{index: nil, location: nil, normalized_text: nil, text: nil}

    test "list_text_nodes/0 returns all text_nodes" do
      text_node = text_node_fixture()
      assert List.first(TextNodes.list_text_nodes().entries).id == text_node.id
    end

    test "get_text_node!/1 returns the text_node with given id" do
      text_node = text_node_fixture()
      assert TextNodes.get_text_node!(text_node.id).version_id == text_node.version_id
      assert TextNodes.get_text_node!(text_node.id).location == text_node.location
      assert TextNodes.get_text_node!(text_node.id).text == text_node.text
    end

    test "create_text_node/1 with valid data creates a text_node" do
      valid_attrs = %{
        location: [],
        text: "some text",
        offset: 100,
        urn: "urn:cts:namespace:text_group.work.version:1.1"
      }

      assert {:ok, %TextNode{} = text_node} = TextNodes.create_text_node(valid_attrs)
      assert text_node.location == []
      assert text_node.text == "some text"
    end

    test "create_text_node/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = TextNodes.create_text_node(@invalid_attrs)
    end

    test "update_text_node/2 with valid data updates the text_node" do
      text_node = text_node_fixture()

      update_attrs = %{
        location: [],
        text: "some updated text"
      }

      assert {:ok, %TextNode{} = text_node} = TextNodes.update_text_node(text_node, update_attrs)
      assert text_node.location == []
      assert text_node.text == "some updated text"
    end

    test "update_text_node/2 with invalid data returns error changeset" do
      text_node = text_node_fixture()
      assert {:error, %Ecto.Changeset{}} = TextNodes.update_text_node(text_node, @invalid_attrs)
      assert text_node.text == TextNodes.get_text_node!(text_node.id).text
    end

    test "delete_text_node/1 deletes the text_node" do
      text_node = text_node_fixture()
      assert {:ok, %TextNode{}} = TextNodes.delete_text_node(text_node)
      assert_raise Ecto.NoResultsError, fn -> TextNodes.get_text_node!(text_node.id) end
    end

    test "change_text_node/1 returns a text_node changeset" do
      text_node = text_node_fixture()
      assert %Ecto.Changeset{} = TextNodes.change_text_node(text_node)
    end

    test "list_text_nodes_by_version_between_locations/3 returns text nodes between the given locations" do
      version = TextServer.VersionsFixtures.version_fixture()

      Enum.each(5..10, fn i ->
        text_node_fixture(%{version: version, text: "Text #{i}", location: ["#{i}"]})
      end)

      text_nodes =
        TextNodes.list_text_nodes_by_version_between_locations(version, ["5"], ["7"])

      locations = Enum.map(text_nodes, & &1.location)

      assert Enum.member?(locations, ["5"])
      assert Enum.member?(locations, ["6"])
      assert Enum.member?(locations, ["7"])
      refute Enum.member?(locations, ["8"])
      refute Enum.member?(locations, ["9"])
    end

    test "list_locations_by_version_id/1 returns all TextNode locations for the given version" do
      version = TextServer.VersionsFixtures.text_node_version_fixture()

      Enum.each(5..10, fn i ->
        text_node_fixture(%{version: version, text: "Text #{i}", location: ["#{i}"]})
      end)

      locations = TextNodes.list_locations_by_version_id(version.id)

      assert Enum.member?(locations, ["5"])
      assert Enum.member?(locations, ["6"])
      assert Enum.member?(locations, ["7"])
      assert Enum.member?(locations, ["8"])
      assert Enum.member?(locations, ["9"])
      assert Enum.member?(locations, ["10"])
    end
  end

  describe "TextNode" do
    import TextServer.TextElementsFixtures

    test "tag_graphemes/1 with valid data returns tagged text_node graphemes" do
      start_offset = 1
      end_offset = 3
      text = "test tagging"
      text_node = text_node_fixture(%{text: text})

      text_element =
        text_element_fixture(%{
          start_offset: start_offset,
          start_text_node_id: text_node.id,
          end_text_node_id: text_node.id,
          end_offset: end_offset
        })

      page = TextNodes.list_text_nodes_by_version_id(text_node.version_id)
      node = List.first(page.entries)
      tagged = TextNode.tag_graphemes(node, [])

      assert tagged.location == text_node.location
      assert length(tagged.graphemes_with_tags) == 3

      {tagged_text, tags} = Enum.fetch!(tagged.graphemes_with_tags, 1)
      tag = List.first(tags)
      element_type = TextServer.ElementTypes.get_element_type!(text_element.element_type_id)

      assert tag.name == element_type.name
      assert Enum.join(tagged_text, "") == String.slice(text, start_offset, end_offset - 1)
    end
  end
end
