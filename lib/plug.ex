defmodule Yax.Plug do
  @moduledoc false
  import Plug.Conn

  def init(default), do: default

  def call(conn, params) do
    put_private(
      conn,
      :query,
      conn
      |> fetch_query_params()
      |> Map.get(:params)
      |> Yax.Parser.parse_params()
      |> Yax.Builder.build(params, conn.assigns[:current_user])
    )
  end
end
