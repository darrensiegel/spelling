defmodule Spelling.Content.List do
  use Ecto.Schema
  import Ecto.Changeset

  schema "lists" do
    field :name, :string
    field :week_ending, :date
    has_many :words, Spelling.Content.Word
    timestamps()
  end

  @doc false
  def changeset(list, attrs) do
    list
    |> cast(attrs, [:name, :week_ending])
    |> validate_required([:name, :week_ending])
  end
end
