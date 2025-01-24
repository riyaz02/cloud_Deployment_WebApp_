# cloud_Deployment_WebApp_
Deploy a web application in a cloud-based k8s

# DevOps Engineer Assessment Solution

## Prerequisites
- Terraform CLI
- Google Cloud SDK
- kubectl
- Docker
- Kubernetes Cluster Access

## Project Structure
```
.
├── Dockerfile
├── index.html
├── k8s
│   ├── deployment.yaml
│   └── prometheus.yaml
├── terraform
│   └── terraform_config.tf
└── README.md
```

## Deployment Steps

### 1. Build Docker Image
```bash
docker build -t devops-assessment-web:v1.0.0 .
```

### 2. Configure Terraform
1. Set GCP Project ID in `terraform/main.tf`
2. Authenticate with GCP
```bash
gcloud auth application-default login
```

### 3. Provision Infrastructure
```bash
cd terraform
terraform init
terraform plan
terraform apply
```

### 4. Configure Kubernetes Context
```bash
gcloud container clusters get-credentials devops-assessment-cluster
```

### 5. Deploy Application
```bash
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/prometheus.yaml
```

## Monitoring
- Prometheus is configured to monitor the deployment
- Access metrics via Kubernetes service

## Notes
- Adjust resource limits as per your infrastructure
- Ensure proper security configurations in production
```
