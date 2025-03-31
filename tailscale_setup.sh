#!/usr/bin/env bash
translator_id=$1
subnet=$2
if [[ -z "$translator_id" ]]; then
  echo Please enter the Tailscale 4via6 subnet translator ID
  read translator_id
fi
if [[ -z "$translator_id" ]]; then
  exit
fi
if [[ -z "$subnet" ]]; then
  echo Enter the subnet for the router default is 192.168.1.0
  read subnet
fi
if [[ -z "$subnet" ]]; then
  subnet="192.168.1.0"
fi

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

