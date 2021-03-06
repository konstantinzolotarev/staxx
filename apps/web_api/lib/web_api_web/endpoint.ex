defmodule Staxx.WebApiWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :web_api

  socket "/socket/v1", Staxx.WebApiWeb.V1.UserSocket,
    websocket: true,
    longpoll: false

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :web_api,
    gzip: false,
    only: ~w(css fonts images js schema index.html upload.html favicon.ico robots.txt)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Logger, log: :debug

  plug Plug.Telemetry, event_prefix: [:staxx, :http]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  plug Plug.Session,
    store: :cookie,
    key: "_web_api_key",
    signing_salt: "LqAHZmhH"

  plug Corsica,
    origins: "*",
    allow_headers: :all,
    log: [rejected: :error, invalid: :warn, accepted: :debug]

  plug Staxx.WebApiWeb.Router
end
