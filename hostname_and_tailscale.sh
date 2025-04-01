#!/usr/bin/env bash

# Check if a new hostname is provided as a command-line argument
if [ -z "$1" ]; then
  echo Enter the new hostname
  read new_hostname
fi

# Overwrite the /etc/hostname file
echo "$new_hostname" > /etc/hostname

echo "Successfully set the hostname to: $new_hostname"

# It's also a good practice to update /etc/hosts
# This part is optional but recommended for proper name resolution

# Get the current IP address of the system (you might need to adjust this based on your network setup)
current_ip=$(ip addr show | grep "inet " | awk '{print $2}' | cut -d/ -f1 | head -n 1)

if [ -n "$current_ip" ]; then
  # Create a temporary file with the updated /etc/hosts content
  temp_hosts=$(mktemp)
  grep -v "$(hostname)" /etc/hosts > "$temp_hosts" # Remove the old hostname entry
  echo "$current_ip $new_hostname" >> "$temp_hosts" # Add the new hostname entry
  cat "$temp_hosts" >> /etc/hosts
  rm "$temp_hosts"
  echo "Updated /etc/hosts with the new hostname."
  hostname $new_hostname
else
  echo "Warning: Could not automatically determine the system's IP address. You might need to update /etc/hosts manually."
fi


curl -fsSL https://tailscale.com/install.sh | sh

echo sudo tailscale set --auto-update
sudo tailscale set --auto-update
echo sudo tailscale up
sudo tailscale up
