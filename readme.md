To install Tailscale on a new Raspberry Pi run the following command from the Pi

bash -c "$(wget -qLO - https://raw.githubusercontent.com/ZAAJR/decentral/main/tailscale_setup.sh)"

To rename the host and install Tailscale on new Orange Pi run the following command from the Pi

sudo bash -c "$(wget -qLO - https://raw.githubusercontent.com/ZAAJR/decentral/main/tailscale_host_and_routes.sh)"


To setup Tailscale on a preconfigured Orange Pi

sudo bash -c "$(wget -qLO - https://raw.githubusercontent.com/ZAAJR/decentral/main/tailscale_minimal.sh)"
