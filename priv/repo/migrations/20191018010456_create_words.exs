defmodule Spelling.Repo.Migrations.CreateWords do
  use Ecto.Migration

  def change do
    create table(:words) do
      add :word, :string
      add :clip, :binary
      add :reading, :boolean, default: false, null: false
      add :list_id, references(:lists)

      timestamps()
    end
  end
end
