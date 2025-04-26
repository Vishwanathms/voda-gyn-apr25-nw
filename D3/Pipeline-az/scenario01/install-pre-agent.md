###

```

#!/bin/bash

# Update system packages
sudo apt-get update -y
sudo apt-get upgrade -y

# Install Git
sudo apt-get install -y git

# Install dependencies for Terraform
sudo apt-get install -y curl gnupg software-properties-common

# Add HashiCorp GPG key and repo
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
    sudo tee /etc/apt/sources.list.d/hashicorp.list

# Update and install Terraform
sudo apt-get update -y
sudo apt-get install -y terraform

# Verify installations
git --version
terraform -version

```