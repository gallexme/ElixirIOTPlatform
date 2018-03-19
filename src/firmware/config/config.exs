# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Customize the firmware. Uncomment all or parts of the following
# to add files to the root filesystem or modify the firmware
# archive.

# config :nerves, :firmware,
#   rootfs_overlay: "rootfs_overlay",
#   fwup_conf: "config/fwup.conf"
config :logger, level: :debug

key_mgmt = System.get_env("NERVES_NETWORK_KEY_MGMT") || "WPA-PSK"

config :nerves_network, :default,
  wlan0: [
    ssid: System.get_env("NERVES_NETWORK_SSID"),
    psk: System.get_env("NERVES_NETWORK_PSK"),
    key_mgmt: String.to_atom(key_mgmt)
  ],
  eth0: [
    ipv4_address_method: :dhcp
  ]

# config :firmware, interface: :eth0
config :firmware, interface: :wlan0
# config :firmware, interface: :usb0

config :ui, UiWeb.Endpoint,
  http: [port: 80],
  url: [host: "localhost", port: 80],
  secret_key_base: "RzmiWYDzEdA6n6X+liCFJoQGpfr1pp079Di0zddmCLSRNBBW4asl23YfxNbJnzR4",
  root: Path.dirname(__DIR__),
  server: true,
  check_origin: false,
  render_errors: [accepts: ~w(html json)],
  pubsub: [name: Firmware.Common.PubSub,
           adapter: Phoenix.PubSub.PG2]

config :ui, Ui.Repo,
  adapter: Sqlite.Ecto2,
  database: "/root/nerves.sqlite3",
  pool_size: 20

config :ui, ecto_repos: [Ui.Repo]

config :firmware,
  ifname: "eth0",
  address_method: :dhcp,
  mdns_domain: nil,
  node_name: "iot_platform",
  node_host: :ip

# Use bootloader to start the main application. See the bootloader
# docs for separating out critical OTP applications such as those
# involved with firmware updates.
config :bootloader,
  init: [:nerves_runtime, :nerves_network],
  app: :firmware

  config :nerves_firmware_ssh,
  authorized_keys: [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDMyqsoNsTWSuECfDVG0aXBEdGqVx/drKe2Bxn19084MwWcf+ZTHBR+RrDrM/0BxRA+WwJMxsKtRAsySRXMLqScN7OAfmYQOb9WmKqglXu8zsCgeIjDFbGXQU//SWm/U2qXsSZ1XHLi2sTFnmVvjOEbLbXIqFKplok326d3BmNLtZpYfqZbQZzLo+PChuWbFrLjOWdrNovQlXgiH80BL95wgTuz/h3sNE6jREM0bbVCPnp77VfwgnI1sPxw6FPmunlR/CQiHxdJ1T/9PE4R9IczkhRqvtKwxcUS3AGA8/XYpQOMQXvSPDapfWNTAlYD/2V7B8Tdif0X0jHWI8yaMsw3",
  ]
# Import target specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
# Uncomment to use target specific configurations

# import_config "#{Mix.Project.config[:target]}.exs"
config :sentry,
  dsn: "https://d304ccbf804d4014b37c09eb47d2818e:8ec7d872b90c4b49ad1dafef2225ced0@sentry.io/306264",
  environment_name: Mix.env,
  enable_source_code_context: true,
  root_source_code_path: File.cwd!<>"/../",
  tags: %{
    env: "dev"
  },
  included_environments: [:dev]
