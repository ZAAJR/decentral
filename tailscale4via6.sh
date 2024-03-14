#!/usr/bin/env bash

routes="'tailscale debug via $translator_id 192.168.1.0/24'"
echo $routes

tailscale up --advertise-routes=$routes
