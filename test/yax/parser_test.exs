defmodule CodexQL.ParserTest do
  use ExUnit.Case, async: true
  alias Yax.Parser

  test "parses select fields" do
    parsed = Parser.parse_params(%{"select" => "id,inserted_at"})
    assert parsed == [select: [:id, :inserted_at]]
  end

  test "parses select all" do
    parsed = Parser.parse_params(%{"select" => "*"})
    assert parsed == [select: [:*]]
  end

  test "parses assoc select fields" do
    parsed = Parser.parse_params(%{"select" => "*,embedded(id)"})
    assert parsed == [select: [:*], assoc: %{embedded: [select: [:id]]}]
  end

  test "parses assoc select all" do
    parsed = Parser.parse_params(%{"select" => "*,embedded(*)"})
    assert parsed == [select: [:*], assoc: %{embedded: [select: [:*]]}]
  end

  test "parses deeply nested association select all" do
    ~w(some deeply nested association)a
    parsed = Parser.parse_params(%{"select" => "*,some.deeply.nested.association(*)"})

    assert parsed == [
             select: [:*],
             assoc: %{
               some: [
                 assoc: %{deeply: [assoc: %{nested: [assoc: %{association: [select: [:*]]}]}]}
               ]
             }
           ]
  end

  test "adds filter conditions" do
    parsed = Parser.parse_params(%{"id" => "10"})
    assert parsed == [where: [id: "10"]]
  end

  test "adds operational conditions" do
    parsed = Parser.parse_params(%{"id" => "lt.13"})
    assert parsed == [where: [id: [:lt, "13"]]]
  end

  test "adds complex operational conditions" do
    parsed = Parser.parse_params(%{"id" => "not.lt.13"})
    assert parsed == [where: [id: [:not, :lt, "13"]]]
  end

  test "adds assoc filter conditions" do
    parsed = Parser.parse_params(%{"id" => "10", "embedded.status" => "active"})
    assert parsed == [assoc: %{embedded: [where: [status: "active"]]}, where: [id: "10"]]
  end

  test "adds deeply nested association filter conditions" do
    parsed = Parser.parse_params(%{"some.deeply.nested.association.status" => "active"})

    assert parsed == [
             assoc: %{
               some: [
                 assoc: %{
                   deeply: [
                     assoc: %{nested: [assoc: %{association: [where: [status: "active"]]}]}
                   ]
                 }
               ]
             }
           ]
  end

  test "adds order conditions" do
    parsed = Parser.parse_params(%{"order" => "inserted_at"})
    assert parsed == [order_by: [asc: :inserted_at]]
  end

  test "adds explicit order conditions" do
    parsed = Parser.parse_params(%{"order" => "inserted_at.desc"})
    assert parsed == [order_by: [desc: :inserted_at]]
  end

  test "composite test" do
    parsed =
      Parser.parse_params(%{
        "id" => "10",
        "select" => "id,inserted_at,some.deeply(*),some.deeply.nested.association(id)",
        "order" => "inserted_at.desc",
        "some.deeply.nested.association.status" => "active"
      })

    assert parsed == [
             where: [id: "10"],
             order_by: [desc: :inserted_at],
             select: [:id, :inserted_at],
             assoc: %{
               some: [
                 assoc: %{
                   deeply: [
                     select: [:*],
                     assoc: %{
                       nested: [assoc: %{association: [select: [:id], where: [status: "active"]]}]
                     }
                   ]
                 }
               ]
             }
           ]
  end
end
