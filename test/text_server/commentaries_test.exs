defmodule TextServer.CommentariesTest do
  use TextServer.DataCase

  alias TextServer.Commentaries

  describe "canonical_commentaries" do
    alias TextServer.Commentaries.CanonicalCommentary

    import TextServer.CommentariesFixtures
    import TextServer.CommentaryCreatorsFixtures

    @invalid_attrs %{filename: nil, pid: nil}

    test "list_public_commentaries/0 returns all public canonical_commentaries" do
      _canonical_commentary = canonical_commentary_fixture()
      assert Commentaries.list_public_commentaries() == []
    end

    test "get_canonical_commentary!/1 returns the canonical_commentary with given id" do
      canonical_commentary = canonical_commentary_fixture()

      comm = Commentaries.get_canonical_commentary!(canonical_commentary.id)

      assert comm.title == canonical_commentary.title
    end

    test "create_canonical_commentary/1 with valid data creates a canonical_commentary" do
      valid_attrs = %{
        filename: "some filename",
        pid: "some pid",
        creators: [creator_fixture()],
        languages: ["grc", "ita"],
        title: "some title",
        publication_date: 1980,
        public_domain_year: 1908,
        urn: "urn:cts:greekLit:tlg0011.tlg003.ajmc-lob"
      }

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

      assert canonical_commentary.title ==
               Commentaries.get_canonical_commentary!(canonical_commentary.id).title
    end

    @tag :skip
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
