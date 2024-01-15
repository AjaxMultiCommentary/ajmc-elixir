defmodule TextServer.Commentaries.Creator do
  use Ecto.Schema
  import Ecto.Changeset

  schema "creators" do
    field :first_name, :string
    field :last_name, :string
    field :creator_type, :string

    timestamps()
  end

  @doc false
  def changeset(creator, attrs) do
    creator
    |> cast(attrs, [:first_name, :last_name, :creator_type])
    |> validate_required([:first_name, :last_name, :creator_type])
  end
end
