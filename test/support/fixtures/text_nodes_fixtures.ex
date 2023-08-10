defmodule TextServer.TextNodesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TextServer.TextNodes` context.
  """

  @doc """
  Generate a text_node.
  """
  def version_text_node_fixture(version, attrs \\ %{}) do
    location = Map.get(attrs, :location, [200, 1, 1])

    {:ok, text_node} =
      attrs
      |> Enum.into(%{
        version_id: version.id,
        location: location,
        text: "some text",
        urn: "#{version.urn}:#{Enum.join(location, ".")}"
      })
      |> TextServer.TextNodes.create_text_node()

    text_node
  end

  @doc """
  Generate a text_node.
  """
  def text_node_fixture(attrs \\ %{}) do
    version = Map.get(attrs, :version, version_fixture())
    location = Map.get(attrs, :location, [100, 1, 1])

    {:ok, text_node} =
      attrs
      |> Enum.into(%{
        version_id: version.id,
        location: location,
        text: "some text",
        urn: "#{version.urn}:#{Enum.join(location, ".")}"
      })
      |> TextServer.TextNodes.create_text_node()

    text_node
  end

  defp version_fixture do
    TextServer.VersionsFixtures.text_node_version_fixture()
  end
end
