defmodule Staxx.WebApiWeb.Api.V1.UserController do
  use Staxx.WebApiWeb, :controller

  require Logger
  alias Staxx.Store.Models.User

  alias Staxx.WebApiWeb.Api.V1.SuccessView
  alias Staxx.WebApiWeb.Schemas.UserSchema

  action_fallback Staxx.WebApiWeb.Api.V1.FallbackController

  @doc """
  List of all users in system
  """
  @spec list(Plug.Conn.t(), map) :: Plug.Conn.t()
  def list(conn, params) do
    with users <- User.list(Map.get(params, "limit", 50), Map.get(params, "offset", 0)) do
      conn
      |> put_status(200)
      |> put_view(SuccessView)
      |> render("200.json", data: users)
    end
  end

  @doc """
  Create new user in system
  """
  @spec create(Plug.Conn.t(), %{optional(binary) => any}) :: Plug.Conn.t()
  def create(conn, params) do
    with :ok <- UserSchema.validate(params),
         {:ok, user} <- User.create(params) do
      conn
      |> put_status(200)
      |> put_view(SuccessView)
      |> render("200.json", data: user)
    end
  end

  @doc """
  Update given user
  """
  @spec update(Plug.Conn.t(), %{optional(binary) => any}) :: Plug.Conn.t()
  def update(conn, %{"id" => user_id} = params) do
    with :ok <- UserSchema.validate(params),
         %User{} = user <- User.get(user_id),
         {:ok, updated} <- User.update(user, params) do
      conn
      |> put_status(200)
      |> put_view(SuccessView)
      |> render("200.json", data: updated)
    end
  end

  @doc """
  Get user details
  """
  @spec get(Plug.Conn.t(), map) :: nil | Plug.Conn.t()
  def get(conn, %{"id" => user_id}) do
    with %User{} = user <- User.get(user_id) do
      conn
      |> put_status(200)
      |> put_view(SuccessView)
      |> render("200.json", data: user)
    end
  end
end
