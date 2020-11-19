defmodule Yax.Parser do
  @moduledoc false

  @operators ~w(eq gt gte lt lte neq like ilike in is fts plfts phfts wfts cs cd ov sl sr nxr nxl adj not)a
  def parse_params(params) do
    Enum.reduce(params, [], &parse_param/2)
  end

  defp parse_param({"select", value}, agg) do
    {:ok, matches, _, _, _, _} = QueryParser.select(value)

    Enum.reduce(matches, agg, &parse_select/2)
  end

  defp parse_param({"order", value}, agg) do
    default =
      case String.split(value, ".") do
        [field] ->
          [asc: String.to_existing_atom(field)]

        [field, direction] ->
          [{String.to_existing_atom(direction), String.to_existing_atom(field)}]
      end

    Keyword.update(agg, :order_by, default, &Keyword.merge(&1, default))
  end

  defp parse_param({other, value}, agg) do
    [field | assocs] = other |> String.split(".") |> Enum.reverse()
    assocs = Enum.reverse(assocs)
    field = String.to_existing_atom(field)

    value =
      case String.split(value, ".") do
        [one] -> one
        many -> Enum.map(many, &to_operator_atom/1)
      end

    default = [{field, value}]

    case assocs do
      [] ->
        Keyword.update(
          agg,
          :where,
          default,
          &Keyword.put(&1, field, value)
        )

      other ->
        update_assoc(agg, other, fn v ->
          Keyword.update(v, :where, default, &Keyword.put(&1, field, value))
        end)
    end
  end

  defp parse_select([assoc, fields], agg)
       when is_binary(assoc) and is_list(fields) do
    value = Enum.map(fields, &String.to_existing_atom/1)
    path = String.split(assoc, ".")

    update_assoc(agg, path, fn v ->
      Keyword.update(
        v,
        :select,
        value,
        &(&1 ++ value)
      )
    end)
  end

  defp parse_select(fields, agg)
       when is_list(fields) do
    value = Enum.map(fields, &String.to_existing_atom/1)

    Keyword.update(
      agg,
      :select,
      value,
      &(&1 ++ value)
    )
  end

  @spec update_assoc(keyword, [binary, ...], (keyword -> keyword)) :: keyword
  defp update_assoc(agg, [assoc], updater) do
    assoc = String.to_existing_atom(assoc)
    default = updater.([])

    Keyword.update(
      agg,
      :assoc,
      %{assoc => default},
      &Map.update(&1, assoc, default, updater)
    )
  end

  defp update_assoc(agg, [assoc | rest], updater) do
    assoc = String.to_existing_atom(assoc)
    default = update_assoc([], rest, updater)

    Keyword.update(
      agg,
      :assoc,
      %{assoc => default},
      fn x -> Map.update(x, assoc, default, &update_assoc(&1, rest, updater)) end
    )
  end

  defp to_operator_atom(str),
    do:
      if(@operators |> Enum.map(&to_string/1) |> Enum.member?(str),
        do: String.to_existing_atom(str),
        else: str
      )
end

defmodule QueryParser do
  @moduledoc false
  import NimbleParsec

  field = ascii_string([?a..?z, ?_, ?*, ?.], min: 1)
  separator = optional(string(","))
  fields = repeat(field |> ignore(separator))

  group =
    ignore(string("("))
    |> wrap(fields)
    |> ignore(string(")"))

  token =
    field
    |> optional(group)

  defparsec :select,
            repeat(
              wrap(token)
              |> ignore(separator)
            )
end
