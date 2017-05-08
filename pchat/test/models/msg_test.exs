defmodule Pchat.MsgTest do
  use Pchat.ModelCase

  alias Pchat.Msg

  @valid_attrs %{msg: "some content", who: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Msg.changeset(%Msg{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Msg.changeset(%Msg{}, @invalid_attrs)
    refute changeset.valid?
  end
end
