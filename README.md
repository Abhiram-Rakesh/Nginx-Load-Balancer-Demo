# Nginx-Load-Balancer-Demo

## Overview

This project demonstrates how to run multiple Nginx web server containers (web1,web2,web3) behind an Nginx load balancer container which would all be hosted on a single AWS EC2 instance

The setup uses Docker Compose to orchestrate 4 containers:

- web1 - Nginx web server
- web2 - Nginx web server
- web3 - Nginx web server
- lb - Nginx reverse proxy that acts as a load balancer that distributes traffic to web1,web2,web3 using the default round robin method.

This architecture simulates a typical load balanced microservice environment and is ideal for learning Nginx upstream configuration, Docker Compose, networking, and infrastructure basics.

## Architechture

Given below is the simple architecture diagram of this project flow
<img width="1022" height="872" alt="nginx-lb-demo" src="https://github.com/user-attachments/assets/00d21593-3979-4d3e-8535-5a54134fe3c7" />

## Prerequisites

### AWS

- 1 EC2 Instance (Amazon Linux 2 recommended)
- Security Group inbound rules:
  - SSH (22) - required
  - HTTP (80) - must be added for LB access

### EC2 Host Requirements

- Docker installed
- Docker Compose installed

## Installation Instructions

### Option 1: Via automated scripts (recommended)

This method uses the included automation script that does the following:

- Automatically detects your os release and install Docker
- Install Docker Compose
- Validates the main configuration files
- Starts the Nginx load balancer + web servers
- Run health checks

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
  - Detect the project root
  - Install Docker (if missing)
  - Install Docker COmpose
  - Start the full stack
  - Test connectivity
  - Print troubleshoot instructions

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

## Troubleshooting Guide

Once the stack is installed and running, you can verify functionality using the commands below.

### 1. Test the Load Balancer from the EC2 instance

Run:

```
curl localhost
```

Expected output (rotating every time you run it):

```
web1
web2
web3
```

This confirms:

- The LB container is running
- Nginx is forwarding requests to backend containers
- Internal networking (appnet) is working

### 2. Test the Load Balancer from your PC

Open in following IP in your browser

```
http://<EC2-PUBLIC-IP>/
```

Or test via terminal:

```
curl http://<EC2-PUBLIC-IP>/
```

You should again see:

```
web1
web2
web3
```

If the browser hangs, check Security Group prot:

- Inbound rule: TCP 80 -> 0.0.0.0/0 (or "My IP")

### 3. Test backend containers directly from the LB

Connect to your web containers and run the curl command.

```
docker exec lb curl http://web1/
docker exec lb curl http://web2/
docker exec lb curl http://web3/
```

Expected:

```
<h1>web1</h1>
<h1>web2</h1>
<h1>web3</h1>
```

This confirms:

- The LB can resolve backend container names via DNS
- Each backend container is accessible
- Docker network (appnet) is configured correctly

### 4. Verify containers are running

Edit the docker list format so that the ports are clearly visible

```
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

Expected:

```
lb     Up ...   0.0.0.0:80->80/tcp
web1   Up ...
web2   Up ...
web3   Up ...
```

If lb is missing, the stack dident start correctly

#### 5. Inspect LB Logs

```
docker logs lb
```

You should not see errors like:

- host not found in upstream
- connect() failed
- connection refused
  If you do, your containers are not attached to the same network.

#### 6. Test port listening on host

```
sudo ss -ltnp | grep ':80'
```

Expected:

```
0.0.0.0:80    LISTEN    ... docker-proxy
```

This confirms the host is correctly exposing port 80 to the LB container.

## Recap

Key concepts used in this demo

#### Docker Compose Networking

All containers share the same appnet bridge, enabling hostname based routing (web1, web2, web3)

#### Bind Mounts

Each web container mounts a unique index.html file from the host.

#### Reverse Proxying

The LB uses proxy_pass to forward requests to upstream servers.

#### Header Forwarding

- $host - preserve original hostname
- $remote_addr - client real IP
- $proxy_add_xforwarded_for - full chain of proxy IPs

#### Upstream Load Balancing

used a reverse proxy based upstream Load Balancing at default Round Robin method.
