#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status
exec > /var/log/jenkins-startup.log 2>&1  # Redirect all output to a log file
echo "Starting Jenkins installation..."

# Update and install dependencies
apt-get update
apt-get install -y openjdk-17-jdk curl apt-transport-https ca-certificates software-properties-common gnupg2 lsb-release

# Create jenkins user if it doesn't exist
if ! id "jenkins" &>/dev/null; then
    useradd -m -s /bin/bash jenkins
fi

# Add jenkins user to sudoers
echo "support@ctengineering.de ALL=(ALL) NOPASSWD: /bin/su - jenkins" | tee /etc/sudoers.d/jenkins
chmod 440 /etc/sudoers.d/jenkins  # Ensure correct permissions for sudoers file

# Install Jenkins
# Import Jenkins GPG key
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | apt-key add -

# Add Jenkins repository
echo "deb http://pkg.jenkins.io/debian-stable binary/" | tee /etc/apt/sources.list.d/jenkins.list

# Update package index and install Jenkins
apt-get update
apt-get install -y jenkins

# Ensure Jenkins is running as the jenkins user
sed -i 's/JENKINS_USER=.*/JENKINS_USER=jenkins/' /etc/default/jenkins

# Start and enable Jenkins
systemctl start jenkins
systemctl enable jenkins

# Install Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list

# Update package index and install Docker
apt-get update
apt-get install -y docker-ce
usermod -aG docker jenkins

# Install kubectl
KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl  # Clean up

# Install Terraform
curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list

# Update package index and install Terraform
apt-get update
apt-get install -y terraform

# Install Google Cloud SDK
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
apt-get update
apt-get install -y google-cloud-sdk

# Install Helm
curl https://baltocdn.com/helm/signing.asc | apt-key add -
echo "deb [signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list

# Update package index and install Helm
apt-get update
apt-get install -y helm

# Restart Jenkins to apply changes
systemctl restart jenkins
