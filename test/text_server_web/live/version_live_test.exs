defmodule TextServerWeb.VersionLiveTest do
  use TextServerWeb.ConnCase

  import Phoenix.LiveViewTest

  defp create_version(_) do
    version = TextServer.VersionsFixtures.version_fixture()
    TextServer.TextNodesFixtures.version_text_node_fixture(version)
    %{version: version}
  end

  describe "Show" do
    setup [:create_version]

    test "displays version", %{conn: conn, version: version} do
      assert {:error, {:live_redirect, %{to: _to}}} =
               live(
                 conn,
                 Routes.version_show_path(conn, :show, version)
               )
    end
  end
end
