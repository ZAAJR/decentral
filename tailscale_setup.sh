#!/usr/bin/env bash

is_valid_ipv4() {
  local ip_address="$1"
  local ipv4_regex='^([0-9]{1,3}\.){3}[0-9]{1,3}$'

  if [[ "$ip_address" =~ $ipv4_regex ]]; then
    local octet
    IFS='.' read -ra octets <<< "$ip_address"
    for octet in "${octets[@]}"; do
      if [[ "$octet" -gt 255 || "$octet" -lt 0 ]]; then
        return 1
      fi
    done
    return 0
  else
    return 1
  fi
}


translator_id=$1
subnet=$2
if [[ -z "$translator_id" ]]; then
  echo Please enter the Tailscale 4via6 subnet translator ID
  read translator_id
fi
if [[ -z "$translator_id" ]]; then
  echo No translator ID specified
  exit
else
  echo Translator ID: $translator_id
fi
if [[ -z "$subnet" ]]; then
  echo Enter the subnet for the router [default is 192.168.1.0]
  read subnet
fi
if [[ -z "$subnet" ]]; then
  subnet="192.168.1.0"
fi

if ! is_valid_ipv4 "$subnet"; then
  echo Invalid IP subnet specified
  exit
fi

echo Subnet: $subnet

sudo apt-get -y install apt-transport-https
curl -fsSL https://pkgs.tailscale.com/stable/raspbian/bullseye.noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg > /dev/null
curl -fsSL https://pkgs.tailscale.com/stable/raspbian/bullseye.tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list
sudo apt-get -y update
sudo apt-get -y install tailscale
#sudo tailscale up
echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
sudo sysctl -p /etc/sysctl.d/99-tailscale.conf

routes=$(tailscale debug via $translator_id $subnet/24)
echo $routes
echo sudo tailscale set --auto-update
sudo tailscale set --auto-update
echo sudo tailscale up --advertise-routes=$routes
sudo tailscale up --advertise-routes=$routes
