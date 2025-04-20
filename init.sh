#!/bin/bash

# Arg check
if [[ "$1" != "m" && "$1" != "w" ]]; then
  echo "Usage: $0 [m|w]"
  echo "  m - configure as master node"
  echo "  w - configure as worker node"
  exit 1
fi

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# Install Docker
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Install firewalld
sudo apt-get install -y firewalld

if [[ "$1" == "m" ]]; then
  echo "Configuring master node"
  sudo firewall-cmd --add-port=2376/tcp --permanent
  sudo firewall-cmd --add-port=7946/tcp --permanent
  sudo firewall-cmd --add-port=7946/udp --permanent
  sudo firewall-cmd --add-port=4789/udp --permanent
  sudo firewall-cmd --reload
  sudo systemctl restart docker
elif [[ "$1" == "w" ]]; then
  echo "Configuring worker node"
  sudo firewall-cmd --add-port=2376/tcp --permanent
  sudo firewall-cmd --add-port=7946/tcp --permanent
  sudo firewall-cmd --add-port=7946/udp --permanent
  sudo firewall-cmd --add-port=4789/udp --permanent
  sudo firewall-cmd --reload
  sudo systemctl restart docker
fi

echo "Recommend to reboot machine."
