defmodule TextServer.Accounts.Authorization do
  alias TextServer.Commentaries.CanonicalCommentary
  alias TextServer.Accounts.User

  def can_view_commentary?(nil, %CanonicalCommentary{} = commentary) do
    CanonicalCommentary.is_public_domain?(commentary)
  end

  def can_view_commentary?(%User{} = _current_user, %CanonicalCommentary{} = _commentary) do
    true
  end
end
