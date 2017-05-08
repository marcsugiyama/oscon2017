defmodule Pchat.Repo.Migrations.CreateMsg do
  use Ecto.Migration

  def change do
    create table(:msgs) do
      add :who, :string
      add :msg, :string

      timestamps()
    end

  end
end
