# Startup Infrastructure

This repository is part of a series of articles on Habr about how to build DevOps infrastructure for small projects with minimal effort and cost.  
In the first part, we focused on the basic environment setup.

[Part 1 — Environment Setup](https://habr.com/ru/articles/904234/)  
[Part 2 — Coming soon..]()

You can find the Russian version of this README here: [README in English](README.md)

## Description
This infrastructure is aimed at startups that do not have the budget for a full DevOps team but need a reliable and scalable system with minimal costs. We considered using Docker Swarm as an alternative to Kubernetes, as it is easier to set up and maintain.

Technologies:
- **Docker Swarm** — a lightweight alternative to Kubernetes for orchestration.
- **Portainer** — a GUI for managing Docker infrastructure.
- **Traefik** — a modern reverse proxy with auto SSL support.

## Quick Start

### 1. Initialize Nodes

Install dependencies and initialize Swarm (on the master node):
```
curl -fsSL https://raw.githubusercontent.com/shampsdev/startup-infrastructure/main/init.sh | bash -s -- m  
docker swarm init --advertise-addr <your-private-ip>
```
Connect worker nodes:
```
curl -fsSL https://raw.githubusercontent.com/shampsdev/startup-infrastructure/main/init.sh | bash -s -- w  
docker swarm join --token <token> <master-ip>:2377
```
### 2. Install Portainer
Portainer helps manage clusters via a convenient web interface.
```
curl -o docker-compose.yaml https://raw.githubusercontent.com/shampsdev/startup-infrastructure/main/portainer-traefik/portainer.docker-compose.yaml  
docker stack deploy -c docker-compose.yaml portainer
```
Open `http://<server-ip>:9000` and create a user.

### 3. Set up Traefik
Traefik handles routing and SSL.

- Create a config in Portainer: Configs > Add config.
- Paste the contents of `traefik.docker-compose.yaml` and set up the stack in Stacks > Add stack.
- Generate a password for dashboard access:
```
    echo $(htpasswd -nB admin) | sed -e s/\\$/\\$\\$/g
```
When connecting services, you can use these labels:
```
labels:
  - "traefik.enable=true"
  - "traefik.docker.network=traefik"
  - "traefik.http.routers.my-service.rule=Host(example.com)"
  - "traefik.http.routers.my-service.entrypoints=https"
  - "traefik.http.routers.my-service.certresolver=letsEncrypt"
  - "traefik.http.services.my-service.loadbalancer.server.port=80"
```
### 4. Repository Structure
```
startup-infrastructure/  
├── init.sh                          # Node initialization script  
├── portainer-traefik/  
│   ├── portainer.docker-compose.yaml  
│   ├── traefik-config-v1            # Traefik config  
│   └── traefik.docker-compose.yaml  
└── README.md                        # Description and documentation
```