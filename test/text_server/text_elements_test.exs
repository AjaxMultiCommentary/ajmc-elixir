defmodule TextServer.TextElementsTest do
  use TextServer.DataCase

  alias TextServer.TextElements
  alias TextServer.TextElements.TextElement

  import TextServer.TextElementsFixtures

  @valid_attrs %{
    attributes: %{},
    content: "some content",
    end_offset: 5,
    start_offset: 0
  }
  @invalid_attrs %{attributes: nil, end_urn: nil}

  describe "text_elements" do
    test "list_text_elements/0 returns all text_elements" do
      text_element = text_element_fixture()
      assert TextElements.list_text_elements() == [text_element]
    end

    test "get_text_element!/1 returns the text_element with given id" do
      text_element = text_element_fixture()
      assert TextElements.get_text_element!(text_element.id) == text_element
    end

    test "create_text_element/1 with valid data creates a text_element" do
      element_type = TextServer.ElementTypesFixtures.element_type_fixture()

      end_text_node =
        TextServer.TextNodesFixtures.text_node_fixture() |> TextServer.Repo.preload(:version)

      start_text_node =
        TextServer.TextNodesFixtures.version_text_node_fixture(end_text_node.version)

      assert {:ok, %TextElement{} = text_element} =
               @valid_attrs
               |> Map.put(:element_type_id, element_type.id)
               |> Map.put(:end_text_node_id, end_text_node.id)
               |> Map.put(:start_text_node_id, start_text_node.id)
               |> TextElements.create_text_element()

      assert text_element.attributes == %{}
      assert text_element.content == "some content"
      assert text_element.end_offset == 5
      assert text_element.start_offset == 0
    end

    test "create_text_element/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = TextElements.create_text_element(@invalid_attrs)
    end

    test "update_text_element/2 with valid data updates the text_element" do
      text_element = text_element_fixture()
      update_attrs = %{attributes: %{}, end_offset: 6}

      assert {:ok, %TextElement{} = text_element} =
               TextElements.update_text_element(text_element, update_attrs)

      assert text_element.attributes == %{}
      assert text_element.end_offset == 6
    end

    test "update_text_element/2 with invalid data returns error changeset" do
      text_element = text_element_fixture()

      assert {:error, %Ecto.Changeset{}} =
               TextElements.update_text_element(text_element, @invalid_attrs)

      assert text_element == TextElements.get_text_element!(text_element.id)
    end

    test "delete_text_element/1 deletes the text_element" do
      text_element = text_element_fixture()
      assert {:ok, %TextElement{}} = TextElements.delete_text_element(text_element)
      assert_raise Ecto.NoResultsError, fn -> TextElements.get_text_element!(text_element.id) end
    end

    test "change_text_element/1 returns a text_element changeset" do
      text_element = text_element_fixture()
      assert %Ecto.Changeset{} = TextElements.change_text_element(text_element)
    end
  end
end
