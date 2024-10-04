#!/bin/bash

# Function to remove Docker containers, images, volumes, and networks
remove_docker_entities() {
    echo "Stopping all running containers..."
    docker stop $(docker ps -q)

    echo "Removing all containers..."
    docker rm $(docker ps -a -q)

    echo "Removing all images..."
    docker rmi $(docker images -q)

    echo "Removing all volumes..."
    docker volume rm $(docker volume ls -q)

    echo "Removing all networks..."
    docker network rm $(docker network ls -q)
}

# Function to remove Docker and its related files
remove_docker() {
    echo "Purging Docker and related packages..."
    sudo apt-get purge -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

    echo "Removing Docker directories..."
    sudo rm -rf /var/lib/docker
    sudo rm -rf /var/lib/containerd

    echo "Removing Docker group..."
    sudo groupdel docker
}

# Main execution
echo "Starting Docker removal process..."

remove_docker_entities
remove_docker

echo "Cleaning up residual files..."
sudo apt-get autoremove -y
sudo apt-get autoclean

echo "Docker has been completely removed from your system."

