#!/bin/bash
# Backend provisioning script

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

# Configure Docker Hub authentication if credentials are provided
if [ -n "${dockerhub_username}" ] && [ -n "${dockerhub_password}" ]; then
  echo "Logging into Docker Hub using provided credentials..."
  echo "${dockerhub_password}" | docker login -u "${dockerhub_username}" --password-stdin
  if [ $? -ne 0 ]; then
    echo "Failed to perform Docker login to Docker Hub. Please check credentials and Docker setup."
    exit 1
  fi
  echo "Successfully logged into Docker Hub."
else
  echo "No Docker Hub credentials provided, assuming public image or pre-authenticated environment."
fi

# Pull container image
echo "Pulling Docker image: ${full_image_name}"
docker pull "${full_image_name}"

# Ensure DNS resolution is working before trying to connect to the database
echo "Checking DNS resolution for database host: ${db_host}"
max_attempts=20
attempt=1
while [ $attempt -le $max_attempts ]; do
  echo "DNS resolution attempt $attempt of $max_attempts..."
  if nslookup "${db_host}" > /dev/null 2>&1; then
    echo "Successfully resolved database host: ${db_host}"
    break
  else
    echo "Failed to resolve database host. Waiting 15 seconds before retry..."
    sleep 15
    attempt=$((attempt+1))
  fi
done

if [ $attempt -gt $max_attempts ]; then
  echo "Failed to resolve database host after $max_attempts attempts. Proceeding anyway..."
fi

# Backend container needs DB environment variables
echo "Running Docker container..."
docker run -d -p "${application_port}:${application_port}" \
  -e DB_USERNAME="${db_username}" \
  -e DB_PASSWORD="${db_password}" \
  -e DB_HOST="${db_host}" \
  -e DB_PORT="${db_port}" \
  -e DB_NAME="${db_name}" \
  -e SSL="${db_sslmode}" \
  -e PORT="${application_port}" \
  --restart always \
  "${full_image_name}"

# Log the completion
echo "Backend provisioning completed at $(date)" >> /var/log/provision.log
echo "Script finished. Check /var/log/provision.log and docker logs for status."