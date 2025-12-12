# Nginx-Load-Balancer-Demo

## Overview
This project demonstrates how to run multiple Nginx web server containers (web1,web2,web3) behind an Nginx load balancer container which would all be hosted on a single AWS EC2 instance

The setup uses Docker Compose to orchestrate 4 containers:

* web1 - Nginx web server
* web2 - Nginx web server
* web3 - Nginx web server
* lb - Nginx reverse proxy that acts as a load balancer that distributes traffic to web1,web2,web3 using the default round robin method.

This architecture simulates a typical load balanced microservice environment and is ideal for learning Nginx upstream configuration, Docker Compose, networking, and infrastructure basics.

## Architechture

## Features

## Prerequisites
### AWS
* 1 EC2 Instance (Amazon Linux 2 recommended)
* Security Group inbound rules:
  - SSH (22) - required
  - HTTP (80) - must be added for LB access
### EC2 Host Requirements
* Docker installed
* Docker Compose installed

## Installation Instructions
### Option 1: Via automated scripts (recommended)
This method uses the included automation script that does the following:
* Automatically detects your os release and install Docker
* Install Docker Compose
* Validates the main configuration files
* Starts the Nginx load balancer + web servers
* Run health checks

  #### 1. Clone this repository
  ```
  git clone https://github.com/<your-github-username>/nginx-lb-demo.git
  cd nginx-lb-demo
  ```
  
  #### 2. Run the installer
  ```
  sudo ./scripts/install.sh
  ```
  The installer will automatically:
  * Detect the project root
  * Install Docker (if missing)
  * Install Docker COmpose
  * Start the full stack
  * Test connectivity
  * Print troubleshoot instructions
  
  #### 3. Starting & Stopping the containers after installation
  If the containers are stopped, use
  ```
  docker ps
  ```
  to check if they are live, If they are not start the load balancer setup using the start script
  ```
  sudo ./scripts/start.sh
  ```

  If you intend to stop the containers simply execute the shutdown script
  ```
  sudo ./scripts/stop-stack.sh
  ```
### Option 2: Manual setup
  #### 1. Install Docker
  Install the docker package based off your OS
  Amazon Linux / Amazon Linux 2 / CentOS / RHEL
  ```
  sudo yum update -y
  sudo yum install -y docker
  sudo systemctl enable docker --now
  ```
  Ubuntu / Debian
  ```
  sudo apt update -y
  sudo apt install -y docker.io
  sudo systemctl enable docker --now
  ```

  #### 2. Install Docker Compose
  Try the plugin first:
  ```
  docker compose version
  ```
  If not available, install the standalone binary:
  ```
  sudo curl -L \
  https://github.com/docker/compose/releases/download/v2.29.2/docker-compose-$(uname -s)-$(uname -m) \
  -o /usr/local/bin/docker-compose

  sudo chmod +x /usr/local/bin/docker-compose
  ```

  #### 3. Clone the repository
  ```
  git clone https://github.com/Abhiram-Rakesh/nginx-lb-demo.git
  cd nginx-lb-demo
  ```

  #### 4. Start the stack manually
  If using the plugin:
  ```
  docker compose up -d
  ```
  If using the binary:
  ```
  docker-compose up -d
  ```
 
  #### 5. Verify everything is running
  ```
  docker ps
  ```

  It should show all the containers
  ```
  web1
  web2
  web3
  lb
  ```
## Project File Structure

## Testing

## Troubleshooting Guide

## Recap
