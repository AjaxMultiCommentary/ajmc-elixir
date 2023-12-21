defmodule TextServerWeb.VersionLiveTest do
  use TextServerWeb.ConnCase

  import Phoenix.LiveViewTest
  import TextServer.VersionsFixtures
  import TextServer.WorksFixtures

  defp create_version(_) do
    version = version_fixture()
    %{version: version}
  end

  defp create_work(_) do
    work = work_fixture()
    %{work: work}
  end

  describe "Index" do
    setup [:create_version, :create_work]

    test "lists all versions", %{conn: conn, version: version} do
      {:ok, _index_live, html} = live(conn, Routes.version_index_path(conn, :index))

      assert html =~ "Versions"
      assert html =~ version.description
    end
  end

  describe "Show" do
    setup [:create_version]

    test "displays version", %{conn: conn, version: version} do
      {:ok, _show_live, html} =
        live(
          conn,
          Routes.version_show_path(conn, :show, version)
        )

      assert html =~ version.label
      assert html =~ version.description
    end
  end
end
