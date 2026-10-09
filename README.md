# CI/CD Project

An end-to-end DevOps CI/CD project that automates infrastructure provisioning and application deployment using Terraform, AWS, Docker, GitHub, Jenkins, and Nginx.

## Architecture

Terraform
   ↓
AWS VPC
   ↓
Public Subnets
   ↓
EC2
   ↓
Docker
   ↓
Nginx
   ↓
Static Web Application

GitHub
   ↓
Jenkins
   ↓
Docker Build
   ↓
GitHub Container Registry
   ↓
EC2
   ↓
Docker Container

## Technologies Used

- Terraform
- AWS EC2
- AWS VPC
- AWS Security Groups
- AWS Internet Gateway
- AWS Route Tables
- Docker
- Nginx
- Jenkins
- Git
- GitHub
- GitHub Container Registry
- HTML/CSS/JavaScript

## Infrastructure

Terraform provisions:

- VPC
- Public Subnet 1
- Public Subnet 2
- Internet Gateway
- Route Table
- Security Group
- EC2 Instance

## Security Group

The EC2 security group allows:

| Port | Purpose |
|------|---------|
| 22 | SSH |
| 80 | HTTP |
| 443 | HTTPS |
| Outbound | All traffic |

## Docker

The static website is packaged into a Docker image using Nginx.

Example Dockerfile:

```dockerfile
FROM nginx:alpine

COPY index.html /usr/share/nginx/html/index.html

EXPOSE 80