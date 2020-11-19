defmodule Yax.Builder do
  @moduledoc false
  require Ecto.Query

  def build(params, module, user) do
    build_query(module, params, user)
  end

  defp build_query(q, params, user) do
    Ecto.Query.from(q in q)
    |> Bodyguard.scope(user)
    |> (&add_assocs/3).(params[:assoc], user)
    |> (&add_where/2).(params[:where])
    |> (&add_select/2).(params[:select])
  end

  defp add_select(q, params) do
    case params do
      nil ->
        q

      [] ->
        q

      [:*] ->
        q

      xs ->
        Ecto.Query.select(q, ^xs)
        # Ecto.Query.select(q, [x], map(x, ^xs))
    end
  end

  defp add_assocs(q, params, user) do
    case params do
      nil ->
        q

      assocs when is_map(assocs) ->
        Enum.reduce(assocs, q, &add_assoc(&1, &2, user))
    end
  end

  defp add_where(q, params) do
    case params do
      nil ->
        q

      xs ->
        Enum.reduce(xs, q, &add_where_field/2)
    end
  end

  defp add_where_field({f, "is.not.null"}, q) do
    Ecto.Query.where(q, [x], not is_nil(field(x, ^f)))
  end

  defp add_where_field({field, value}, q) do
    where = Keyword.put([], field, value)
    Ecto.Query.where(q, ^where)
  end

  defp add_assoc({assoc, params}, q, user) do
    {_, source} = q.from.source

    preload = [{assoc, build_query(ref(source, assoc), params, user)}]
    Ecto.Query.preload(q, ^preload)
  end

  defp ref(source, assoc) do
    case source.__schema__(:association, assoc) do
      %Ecto.Association.BelongsTo{related: related} -> related
      %Ecto.Association.Has{related: related} -> related
      %Ecto.Association.HasThrough{owner: owner, through: through} -> ref_through(owner, through)
    end
  end

  defp ref_through(source, [assoc]),
    do: ref(source, assoc)

  defp ref_through(source, [assoc | rest]) do
    ref = ref(source, assoc)
    ref_through(ref, rest)
  end
end
