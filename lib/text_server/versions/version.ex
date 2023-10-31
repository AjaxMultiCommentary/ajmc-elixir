defmodule TextServer.Versions.Version do
  use Ecto.Schema
  import Ecto.Changeset

  schema "versions" do
    field :description, :string
    field :filemd5hash, :string
    field :filename, :string
    field :label, :string
    field :parsed_at, :naive_datetime
    field :source, :string
    field :source_link, :string
    field :structure, {:array, :string}
    field :urn, TextServer.Ecto.Types.CTS_URN
    field :version_type, Ecto.Enum, values: [:commentary, :edition, :translation]

    belongs_to :language, TextServer.Languages.Language
    belongs_to :work, TextServer.Works.Work

    has_many :commentaries, TextServer.Commentaries.CanonicalCommentary
    has_many :text_nodes, TextServer.TextNodes.TextNode
    has_one :xml_document, TextServer.Versions.XmlDocuments.XmlDocument

    embeds_one :tei_header, TextServer.Versions.TeiHeader

    timestamps()
  end

  @doc false
  def changeset(version, attrs) do
    version
    |> cast(attrs, [
      :description,
      :filemd5hash,
      :filename,
      :label,
      :language_id,
      :parsed_at,
      :source,
      :source_link,
      :structure,
      :urn,
      :version_type,
      :work_id
    ])
    |> validate_required([:filemd5hash, :filename, :label, :urn, :version_type])
    |> assoc_constraint(:language)
    |> assoc_constraint(:work)
    |> unique_constraint(:urn)
  end
end
