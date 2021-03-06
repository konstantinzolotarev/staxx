defmodule Staxx.WebApiWeb.Api.V1.StackController do
  use Staxx.WebApiWeb, :controller

  require Logger

  action_fallback Staxx.WebApiWeb.Api.V1.FallbackController

  alias Staxx.Instance
  alias Staxx.EventStream.Notification
  alias Staxx.Instance.Stack
  alias Staxx.Instance.Stack.ConfigLoader

  alias Staxx.WebApiWeb.Api.V1.SuccessView

  # List of available stack configs
  @spec list_config(Plug.Conn.t(), any) :: Plug.Conn.t()
  def list_config(conn, _params) do
    with {:ok, list} <- {:ok, ConfigLoader.get()} do
      conn
      |> put_status(200)
      |> put_view(SuccessView)
      |> render("200.json", data: list)
    end
  end

  # Force to reload config
  @spec reload_config(Plug.Conn.t(), any) :: Plug.Conn.t()
  def reload_config(conn, _) do
    with :ok <- Instance.reload_config() do
      conn
      |> put_status(200)
      |> put_view(SuccessView)
      |> render("200.json", data: %{})
    end
  end

  @spec start(Plug.Conn.t(), map) :: Plug.Conn.t()
  def start(conn, %{
        "instance_id" => instance_id,
        "stack_name" => stack_name
      }) do
    with {:ok, _} <- Instance.start_stack(instance_id, stack_name) do
      conn
      |> put_status(200)
      |> put_view(SuccessView)
      |> render("200.json", data: %{})
    end
  end

  @spec stop(Plug.Conn.t(), map) :: Plug.Conn.t()
  def stop(conn, %{
        "instance_id" => instance_id,
        "stack_name" => stack_name
      }) do
    with :ok <- Instance.stop_stack(instance_id, stack_name) do
      conn
      |> put_status(200)
      |> put_view(SuccessView)
      |> render("200.json", data: %{})
    end
  end

  # Send notification about stack
  @spec notify(Plug.Conn.t(), map) :: Plug.Conn.t()
  def notify(conn, %{
        "instance_id" => instance_id,
        "event" => event,
        "data" => data
      }) do
    with true <- Instance.alive?(instance_id),
         :ok <- Notification.notify(instance_id, event, data) do
      conn
      |> put_status(200)
      |> put_view(SuccessView)
      |> render("200.json", data: %{})
    end
  end

  # Send stack ready notification
  @spec notify_ready(Plug.Conn.t(), map) :: Plug.Conn.t()
  def notify_ready(conn, %{"instance_id" => instance_id, "stack_name" => stack_name}) do
    with :ok <- Stack.set_status(instance_id, stack_name, :ready) do
      conn
      |> put_status(200)
      |> put_view(SuccessView)
      |> render("200.json", data: %{})
    end
  end

  # Send stack failed notification
  @spec notify_failed(Plug.Conn.t(), map) :: Plug.Conn.t()
  def notify_failed(conn, %{"instance_id" => instance_id, "stack_name" => stack_name}) do
    with :ok <- Stack.set_status(instance_id, stack_name, :failed) do
      conn
      |> put_status(200)
      |> put_view(SuccessView)
      |> render("200.json", data: %{})
    end
  end
end
