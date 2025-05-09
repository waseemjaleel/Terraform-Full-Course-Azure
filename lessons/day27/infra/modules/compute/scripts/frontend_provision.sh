#!/bin/bash
# Frontend provisioning script

# Make sure we're running with root privileges
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root. Using sudo..."
  exec sudo "$0" "$@"
fi

# Install necessary packages
apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get install -y apt-transport-https ca-certificates curl software-properties-common dnsutils

# Install Docker
echo "Setting up Docker repository..."
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update -y
echo "Installing Docker..."
DEBIAN_FRONTEND=noninteractive apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Install Azure CLI
echo "Installing Azure CLI..."
curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Start and enable docker service
echo "Starting and enabling Docker service..."
systemctl enable docker
systemctl start docker

# Add adminuser to the docker group
echo "Adding 'adminuser' to the docker group..."
usermod -aG docker adminuser
if [ $? -eq 0 ]; then
  echo "'adminuser' successfully added to the docker group. User will need to log out and log back in for this to take effect in interactive shells."
else
  echo "Warning: Failed to add 'adminuser' to the docker group. Docker commands may require sudo for this user in interactive shells."
fi

# Configure docker to use ACR Admin User credentials for authentication
echo "Logging into ACR (${acr_name}.azurecr.io) using admin user credentials..."
echo "${acr_admin_password}" | docker login "${acr_name}.azurecr.io" -u "${acr_admin_username}" --password-stdin
if [ $? -ne 0 ]; then
  echo "Failed to perform Docker login to ACR. Please check ACR credentials and Docker setup."
  exit 1
fi
echo "Successfully logged into ACR."

# Pull container image
echo "Pulling Docker image: ${full_image_name}"
docker pull "${full_image_name}"

echo "Running Docker container..."
# Frontend container with simpler setup
docker run -d -p "${application_port}:${application_port}" \
  -e PORT="${application_port}" \
  -e BACKEND_URL="http://backend-internal-lb:8080" \
  --restart always \
  "${full_image_name}"

# Log the completion
echo "Frontend provisioning completed at $(date)" >> /var/log/provision.log
echo "Script finished. Check /var/log/provision.log and docker logs for status."