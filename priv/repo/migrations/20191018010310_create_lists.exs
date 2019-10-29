defmodule Spelling.Repo.Migrations.CreateLists do
  use Ecto.Migration

  def change do
    create table(:lists) do
      add :name, :string
      add :week_ending, :date

      timestamps()
    end

  end
end
