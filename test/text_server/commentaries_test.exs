defmodule TextServer.CommentariesTest do
  use TextServer.DataCase

  alias TextServer.Commentaries

  describe "canonical_commentaries" do
    alias TextServer.Commentaries.CanonicalCommentary

    import TextServer.CommentariesFixtures

    @invalid_attrs %{filename: nil, pid: nil}

    test "list_canonical_commentaries/0 returns all canonical_commentaries" do
      canonical_commentary = canonical_commentary_fixture()
      assert Commentaries.list_canonical_commentaries() == [canonical_commentary]
    end

    test "get_canonical_commentary!/1 returns the canonical_commentary with given id" do
      canonical_commentary = canonical_commentary_fixture()

      assert Commentaries.get_canonical_commentary!(canonical_commentary.id) ==
               canonical_commentary
    end

    test "create_canonical_commentary/1 with valid data creates a canonical_commentary" do
      valid_attrs = %{filename: "some filename", pid: "some pid"}

      assert {:ok, %CanonicalCommentary{} = canonical_commentary} =
               Commentaries.create_canonical_commentary(valid_attrs)

      assert canonical_commentary.pid == "some pid"
    end

    test "create_canonical_commentary/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Commentaries.create_canonical_commentary(@invalid_attrs)
    end

    test "update_canonical_commentary/2 with valid data updates the canonical_commentary" do
      canonical_commentary = canonical_commentary_fixture()
      update_attrs = %{pid: "some updated pid"}

      assert {:ok, %CanonicalCommentary{} = canonical_commentary} =
               Commentaries.update_canonical_commentary(canonical_commentary, update_attrs)

      assert canonical_commentary.pid == "some updated pid"
    end

    test "update_canonical_commentary/2 with invalid data returns error changeset" do
      canonical_commentary = canonical_commentary_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Commentaries.update_canonical_commentary(canonical_commentary, @invalid_attrs)

      assert canonical_commentary ==
               Commentaries.get_canonical_commentary!(canonical_commentary.id)
    end

    test "delete_canonical_commentary/1 deletes the canonical_commentary" do
      canonical_commentary = canonical_commentary_fixture()

      assert {:ok, %CanonicalCommentary{}} =
               Commentaries.delete_canonical_commentary(canonical_commentary)

      assert_raise Ecto.NoResultsError, fn ->
        Commentaries.get_canonical_commentary!(canonical_commentary.id)
      end
    end

    test "change_canonical_commentary/1 returns a canonical_commentary changeset" do
      canonical_commentary = canonical_commentary_fixture()
      assert %Ecto.Changeset{} = Commentaries.change_canonical_commentary(canonical_commentary)
    end
  end
end
