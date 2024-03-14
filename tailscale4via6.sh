#!/usr/bin/env bash

echo Please enter the Tailscale 4via6 subnet translator ID
read translator_id

routes=$(tailscale debug via $translator_id 192.168.1.0/24)
echo $routes

echo tailscale up --advertise-routes=$routes

tailscale up --advertise-routes=$routes
