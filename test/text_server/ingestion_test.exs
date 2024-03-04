defmodule TextServer.IngestionTest do
  use TextServer.DataCase

  @commentary_json Path.expand("test/support/fixtures/3467O2_tess_retrained.json")
                   |> File.read!()
                   |> Jason.decode!()

  describe "commentary" do
    test "prepare_lemmas_from_canonical_json/1 properly prepares lemmata" do
      assert TextServer.Ingestion.Commentary.prepare_lemmas_from_canonical_json(@commentary_json)
    end
  end
end
