defmodule TextServer.Versions.Passage do
  use Ecto.Schema
  import Ecto.Changeset

  schema "version_passages" do
    field :passage_number, :integer
    field :label, :string
    field :urn, TextServer.Ecto.Types.CTS_URN
    field :end_location, {:array, :integer}
    field :start_location, {:array, :integer}

    belongs_to :version, TextServer.Versions.Version

    timestamps()
  end

  @doc false
  def changeset(passage, attrs) do
    passage
    |> cast(attrs, [
      :end_location,
      :label,
      :urn,
      :version_id,
      :passage_number,
      :start_location
    ])
    |> validate_required([
      :end_location,
      :passage_number,
      :urn,
      :start_location
    ])
    |> assoc_constraint(:version)
    |> unique_constraint([:version_id, :passage_number])
    |> unique_constraint(:urn)
  end
end
