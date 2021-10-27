defmodule Staxx.WebApiWeb.Api.V1.DockerController do
  use Staxx.WebApiWeb, :controller

  require Logger

  action_fallback Staxx.WebApiWeb.Api.V1.FallbackController

  alias Staxx.WebApiWeb.Api.V1.SuccessView
  alias Staxx.WebApiWeb.Api.V1.ErrorView
  alias Staxx.Docker
  alias Staxx.Docker.Container
  alias Staxx.Instance
  alias Staxx.WebApiWeb.Schemas.DockerSchema

  @spec start(Plug.Conn.t(), %{optional(binary) => any}) :: Plug.Conn.t()
  def start(conn, %{"instance_id" => id, "stack_name" => stack_name} = params) do
    # We wouldn't let users to control `rm` flag for container
    # Otherwise we will have a log of dead containers in our system

    with :ok <- DockerSchema.validate(params),
         container <- Container.create_container(params, id),
         {:ok, container} <- Instance.start_container(id, stack_name, container) do
      Logger.debug("Instance #{id}: Starting new docker container #{inspect(container)}")

      conn
      |> put_status(200)
      |> put_view(SuccessView)
      |> render("200.json", data: encode(container))
    end
  end

  @spec stop(Plug.Conn.t(), map) :: Plug.Conn.t()
  def stop(conn, %{"id" => id}) do
    case Docker.stop(id) do
      :ok ->
        conn
        |> put_status(200)
        |> put_view(SuccessView)
        |> render("200.json", data: "ok")

      {:error, err} ->
        conn
        |> put_status(500)
        |> put_view(ErrorView)
        |> render("500.json", message: err)
    end
  end

  defp encode(%Container{ports: ports} = container) do
    updated_ports =
      ports
      |> Enum.map(&make_port/1)

    %Container{container | ports: updated_ports}
  end

  defp make_port({port, _}), do: port
  defp make_port(port), do: port
end
