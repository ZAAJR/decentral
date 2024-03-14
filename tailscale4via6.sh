routes="'tailscale debug via $translator_id 192.168.1.0/24'"
tailscale up --advertise-routes=$routes
