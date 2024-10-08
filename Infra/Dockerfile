# Use an official Ubuntu as the base image
FROM ubuntu:20.04

# Set environment variable to skip interactive prompts during installations
ENV DEBIAN_FRONTEND=noninteractive

# Update and install basic dependencies
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    curl \
    apt-transport-https \
    ca-certificates \
    software-properties-common \
    sudo \
    gnupg2 \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

# Add jenkins user as per the startup script
RUN useradd -m -s /bin/bash jenkins

# Copy your startup script into the container
COPY startup.sh /usr/local/bin/startup.sh

# Make sure the script is executable
RUN chmod +x /usr/local/bin/startup.sh

# List the file to ensure it's there (debugging step)
RUN ls -l /usr/local/bin/startup.sh

# Expose Jenkins default port (8080) just for reference
EXPOSE 8080

# Run the startup script at container runtime instead of during the build
CMD ["/bin/bash", "/usr/local/bin/startup.sh"]
