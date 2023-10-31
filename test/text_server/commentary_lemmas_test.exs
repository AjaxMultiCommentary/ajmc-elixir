defmodule TextServer.CommentaryLemmasTest do
  use TextServer.DataCase

  alias TextServer.CommentaryLemmas

  describe "commentary_lemmas" do
    alias TextServer.CommentaryLemmas.CommentaryLemma

    import TextServer.CommentaryLemmasFixtures

    @invalid_attrs %{label: nil, shifts: nil, transcript: nil, anchor_target: nil, text_anchor: nil, selector: nil}

    test "list_commentary_lemmas/0 returns all commentary_lemmas" do
      commentary_lemma = commentary_lemma_fixture()
      assert CommentaryLemmas.list_commentary_lemmas() == [commentary_lemma]
    end

    test "get_commentary_lemma!/1 returns the commentary_lemma with given id" do
      commentary_lemma = commentary_lemma_fixture()
      assert CommentaryLemmas.get_commentary_lemma!(commentary_lemma.id) == commentary_lemma
    end

    test "create_commentary_lemma/1 with valid data creates a commentary_lemma" do
      valid_attrs = %{label: "some label", shifts: [1, 2], transcript: "some transcript", anchor_target: %{}, text_anchor: "some text_anchor", selector: "some selector"}

      assert {:ok, %CommentaryLemma{} = commentary_lemma} = CommentaryLemmas.create_commentary_lemma(valid_attrs)
      assert commentary_lemma.label == "some label"
      assert commentary_lemma.shifts == [1, 2]
      assert commentary_lemma.transcript == "some transcript"
      assert commentary_lemma.anchor_target == %{}
      assert commentary_lemma.text_anchor == "some text_anchor"
      assert commentary_lemma.selector == "some selector"
    end

    test "create_commentary_lemma/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = CommentaryLemmas.create_commentary_lemma(@invalid_attrs)
    end

    test "update_commentary_lemma/2 with valid data updates the commentary_lemma" do
      commentary_lemma = commentary_lemma_fixture()
      update_attrs = %{label: "some updated label", shifts: [1], transcript: "some updated transcript", anchor_target: %{}, text_anchor: "some updated text_anchor", selector: "some updated selector"}

      assert {:ok, %CommentaryLemma{} = commentary_lemma} = CommentaryLemmas.update_commentary_lemma(commentary_lemma, update_attrs)
      assert commentary_lemma.label == "some updated label"
      assert commentary_lemma.shifts == [1]
      assert commentary_lemma.transcript == "some updated transcript"
      assert commentary_lemma.anchor_target == %{}
      assert commentary_lemma.text_anchor == "some updated text_anchor"
      assert commentary_lemma.selector == "some updated selector"
    end

    test "update_commentary_lemma/2 with invalid data returns error changeset" do
      commentary_lemma = commentary_lemma_fixture()
      assert {:error, %Ecto.Changeset{}} = CommentaryLemmas.update_commentary_lemma(commentary_lemma, @invalid_attrs)
      assert commentary_lemma == CommentaryLemmas.get_commentary_lemma!(commentary_lemma.id)
    end

    test "delete_commentary_lemma/1 deletes the commentary_lemma" do
      commentary_lemma = commentary_lemma_fixture()
      assert {:ok, %CommentaryLemma{}} = CommentaryLemmas.delete_commentary_lemma(commentary_lemma)
      assert_raise Ecto.NoResultsError, fn -> CommentaryLemmas.get_commentary_lemma!(commentary_lemma.id) end
    end

    test "change_commentary_lemma/1 returns a commentary_lemma changeset" do
      commentary_lemma = commentary_lemma_fixture()
      assert %Ecto.Changeset{} = CommentaryLemmas.change_commentary_lemma(commentary_lemma)
    end
  end
end
