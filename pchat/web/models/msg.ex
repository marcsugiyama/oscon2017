defmodule Pchat.Msg do
  use Pchat.Web, :model

  schema "msgs" do
    field :who, :string
    field :msg, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:who, :msg])
    |> validate_required([:who, :msg])
  end
end
