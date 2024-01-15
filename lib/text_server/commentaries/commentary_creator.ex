defmodule TextServer.Commentaries.CommentaryCreator do
  use Ecto.Schema

  schema "commentary_creators" do
    belongs_to :canonical_commentary, TextServer.Commentaries.CanonicalCommentary
    belongs_to :creator, TextServer.Commentaries.Creator

    timestamps()
  end
end
