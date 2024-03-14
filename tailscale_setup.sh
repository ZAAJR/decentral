#!/usr/bin/env bash

echo Please enter the Tailscale 4via6 subnet translator ID
read translator_id

sudo apt-get -y install apt-transport-https
curl -fsSL https://pkgs.tailscale.com/stable/raspbian/bullseye.noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg > /dev/null
curl -fsSL https://pkgs.tailscale.com/stable/raspbian/bullseye.tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list
sudo apt-get -y update
sudo apt-get -y install tailscale
#sudo tailscale up
echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
sudo sysctl -p /etc/sysctl.d/99-tailscale.conf

routes=$(tailscale debug via $translator_id 192.168.1.0/24)
echo $routes
echo tailscale up --advertise-routes=$routes
tailscale up --advertise-routes=$routes
