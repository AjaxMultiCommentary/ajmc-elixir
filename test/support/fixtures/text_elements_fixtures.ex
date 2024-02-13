defmodule TextServer.TextElementsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TextServer.TextElements` context.
  """

  @doc """
  Generate a text_element.
  """
  def text_element_fixture(attrs \\ %{}) do
    commentary = canonical_commentary_fixture()
    element_type = element_type_fixture()
    text_node = text_node_fixture()

    {:ok, text_element} =
      attrs
      |> Enum.into(%{
        attributes: %{},
        canonical_commentary_id: commentary.id,
        content: "Some content",
        start_offset: 1,
        end_offset: 5,
        element_type_id: element_type.id,
        start_text_node_id: text_node.id,
        end_text_node_id: text_node.id
      })
      |> TextServer.TextElements.create_text_element()

    text_element
  end

  defp canonical_commentary_fixture do
    TextServer.CommentariesFixtures.canonical_commentary_fixture()
  end

  defp element_type_fixture do
    TextServer.ElementTypesFixtures.element_type_fixture()
  end

  defp text_node_fixture do
    TextServer.TextNodesFixtures.text_node_fixture()
  end
end
