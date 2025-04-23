#!/bin/bash

number="$1"
subnet="$2"

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


# Check if a number is provided as a command-line argument
if [ -z $number ]; then
  echo Please enter the Tailscale 4via6 subnet translator ID
  read number
fi


# Check if the input is a number
if ! [[ $number =~ ^[0-9]+$ ]]; then
  echo "Error: The parameter provided must be a number."
  exit 1
fi



# Pad the number with leading zeros to make it 5 digits
translator_id=$number
padded_translator_id=$(printf "%05d" "$number")

# Define the base hostname (you can customize this)
base_hostname="tailscale"

# Construct the new hostname
new_hostname="${base_hostname}-${padded_translator_id}"

# Check if the user has root privileges
if [[ $EUID -ne 0 ]]; then
  echo "Error: This script must be run with root privileges (using sudo)."
  exit 1
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

if [[ -z "$subnet" ]]; then
  echo Enter the subnet for the router [default is 192.168.1.0]
  read subnet
fi
if [[ -z "$subnet" ]]; then
  subnet="192.168.1.0"
fi

echo $subnet

if ! is_valid_ipv4 "$subnet"; then
  echo Invalid IP subnet specified
  exit
fi

parts=(${subnet//./ })
subnet="${parts[0]}.${parts[1]}.${parts[2]}.0"

echo Subnet: $subnet

NETDEV=$(ip -o route get 8.8.8.8 | cut -f 5 -d " ")
sudo ethtool -K $NETDEV rx-udp-gro-forwarding on rx-gro-list off

printf '#!/bin/sh\n\nethtool -K %s rx-udp-gro-forwarding on rx-gro-list off \n' "$(ip -o route get 8.8.8.8 | cut -f 5 -d " ")" | sudo tee /etc/networkd-dispatcher/routable.d/50-tailscale
sudo chmod 755 /etc/networkd-dispatcher/routable.d/50-tailscale

#echo sudo /etc/networkd-...
#sudo /etc/networkd-dispatcher/routable.d/50-tailscale 

#echo test
#test $? -eq 0 || echo 'An error occurred.' && exit 1

echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
sudo sysctl -p /etc/sysctl.d/99-tailscale.conf

echo tailscale debug via $translator_id $subnet/24
routes=$(tailscale debug via $translator_id $subnet/24)
echo $routes

echo sudo tailscale up --advertise-routes=$routes
sudo tailscale up --advertise-routes=$routes --ssh 
#--auth-key=tskey-auth-kLB8yMhNgC21CNTRL-R9cKdG5ZPqTRfKvYdSo1qTvQwiXhpuqu

echo sudo tailscale set --auto-update
sudo tailscale set --auto-update
