defmodule Spelling.Content.Word do
  use Ecto.Schema
  import Ecto.Changeset

  schema "words" do
    field :clip, :binary
    field :reading, :boolean, default: false
    field :word, :string
    belongs_to :lists, Spelling.Content.List, foreign_key: :list_id
    timestamps()
  end

  @doc false
  def changeset(word, attrs) do
    word
    |> cast(attrs, [:word, :clip, :reading, :list_id])
    |> validate_required([:word, :clip, :reading, :list_id])
  end
end
