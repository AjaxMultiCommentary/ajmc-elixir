defmodule TextServer.CommentaryCreatorsFixtures do
  def creator_fixture(attrs \\ %{}) do
    attrs
    |> Enum.into(%{
      first_name: "First Name",
      last_name: "Last Name",
      creator_type: "author"
    })
  end
end
