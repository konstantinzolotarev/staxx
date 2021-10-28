defmodule Staxx.WebApiWeb.Api.V1.InstancesController do
  use Staxx.WebApiWeb, :controller

  require Logger

  action_fallback Staxx.WebApiWeb.Api.V1.FallbackController

  alias Staxx.Instance
  alias Staxx.Store.Models.User, as: UserRecord
  alias Staxx.WebApiWeb.Schemas.TestchainSchema

  alias Staxx.WebApiWeb.Api.V1.SuccessView
  alias Staxx.WebApiWeb.Api.V1.ErrorView

  @spec start(Plug.Conn.t(), map) :: {:error, any} | Plug.Conn.t()
  def start(conn, %{"testchain" => _} = params) do
    Logger.debug(fn -> "#{__MODULE__}: New instance is starting" end)

    with :ok <- TestchainSchema.validate_with_payload(params),
         {:ok, id} <- Instance.start(params, get_user_email(conn)) do
      conn
      |> put_status(200)
      |> put_view(SuccessView)
      |> render("200.json", data: %{id: id})
    end
  end

  @spec stop(Plug.Conn.t(), map) :: {:error, :not_found} | Plug.Conn.t()
  def stop(conn, %{"id" => id}) do
    Logger.debug(fn -> "#{__MODULE__}: Stopping instance #{id}" end)

    with :ok <- Instance.stop(id) do
      conn
      |> put_status(200)
      |> put_view(SuccessView)
      |> render("200.json", data: %{})
    end
  end

  @spec info(Plug.Conn.t(), map) :: Plug.Conn.t()
  def info(conn, %{"id" => id}) do
    Logger.debug(fn -> "#{__MODULE__}: Loading instance #{id} details" end)

    with data when is_map(data) <- Instance.info(id) do
      conn
      |> put_status(200)
      |> put_view(SuccessView)
      |> render("200.json", data: data)
    end
  end

  @spec list(Plug.Conn.t(), any) :: Plug.Conn.t()
  def list(conn, _) do
    Logger.debug(fn -> "#{__MODULE__}: Loading instances list" end)

    list =
      conn
      |> get_user_email()
      |> UserRecord.get_user_id()
      |> Instance.list()

    conn
    |> put_status(200)
    |> put_view(SuccessView)
    |> render("200.json", data: list)
  end

  @spec remove(Plug.Conn.t(), map) :: {:error, <<_::64, _::_*8>>} | Plug.Conn.t()
  def remove(conn, %{"id" => id}) do
    Logger.debug(fn -> "#{__MODULE__}: Removing instance #{id}" end)

    with :ok <- Instance.remove(id) do
      conn
      |> put_status(200)
      |> put_view(SuccessView)
      |> render("200.json", data: %{})
    end
  end
end
