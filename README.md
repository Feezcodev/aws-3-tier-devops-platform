
# AWS 3-Tier DevOps Platform on Amazon EKS

**A hands-on DevOps engineering project demonstrating secure cloud infrastructure, automated CI/CD, DevSecOps practices, Kubernetes orchestration, and infrastructure observability on AWS.**

This project implements an end-to-end deployment workflow for a containerized three-tier web application running on Amazon Elastic Kubernetes Service (EKS).

It combines Terraform-based infrastructure provisioning, Docker containerization, GitHub Actions automation, AWS IAM authentication through OpenID Connect (OIDC), container security scanning, Amazon ECR, Kubernetes deployment, and Prometheus/Grafana monitoring.

The objective is to demonstrate practical DevOps engineering skills through building, deploying, securing, monitoring, and troubleshooting a cloud-native application platform.

---

## 1. Project Overview

The platform is designed around three application tiers:

| Layer | Technology | Responsibility |
|---|---|---|
| Frontend | React.js | User interface |
| Backend | Node.js / Express | Application logic and API |
| Database | MySQL | Data persistence |

The application is containerized with Docker and deployed to Amazon EKS.

GitHub Actions automates the CI/CD process, while AWS services provide the underlying infrastructure, container registry, and secure deployment access.

Prometheus and Grafana provide visibility into Kubernetes infrastructure and worker-node resource utilization.

### Engineering Objectives

- Provision cloud infrastructure using Terraform.
- Automate application delivery with GitHub Actions.
- Build and publish Docker images to Amazon ECR.
- Implement secure AWS authentication using GitHub OIDC.
- Integrate infrastructure and container security checks.
- Deploy and manage workloads on Amazon EKS.
- Troubleshoot Kubernetes scheduling and deployment failures.
- Implement infrastructure monitoring using Prometheus and Grafana.

---

## 2. Architecture Overview

The platform follows a three-tier application architecture deployed on Amazon EKS.

### Application and CI/CD Architecture

```text
                     Developer
                         |
                         v
                    GitHub Repo
                         |
                         v
                GitHub Actions CI/CD
                         |
             +-----------+-----------+
             |                       |
             v                       v
       Security Scanning        Build & Test
       Checkov / Trivy           Docker Images
             |                       |
             +-----------+-----------+
                         |
                         v
                    Amazon ECR
                         |
                         v
                 AWS IAM via OIDC
                         |
                         v
                   Amazon EKS
                         |
                         v
              Kubernetes Namespace
                  three-tier-dev
                         |
             +-----------+-----------+
             |           |           |
             v           v           v
          Frontend     Backend     MySQL
           Pods         Pods        Pods
```

### Monitoring Architecture

```text
                 Amazon EKS Cluster
                         |
             +-----------+-----------+
             |                       |
             v                       v
        Node Exporter          kube-state-metrics
             |                       |
             +-----------+-----------+
                         |
                         v
                     Prometheus
                         |
                         v
                      Grafana
                         |
                         v
                Monitoring Dashboards
```

*The diagrams describe the implemented application delivery and monitoring components. Additional production infrastructure will be added as it is configured and verified.*

---

## 3. Technology Stack

| Category | Technologies |
|---|---|
| Cloud Platform | AWS |
| Compute | Amazon EC2, Amazon EKS |
| Networking | Amazon VPC, Subnets, Security Groups |
| Infrastructure as Code | Terraform |
| Containerization | Docker |
| Orchestration | Kubernetes |
| Container Registry | Amazon ECR |
| CI/CD Automation | GitHub Actions |
| DevSecOps | Checkov, Trivy |
| Identity and Access | AWS IAM, GitHub OIDC, EKS Access Entries |
| Application | React.js, Node.js / Express, MySQL |
| Monitoring | Prometheus, Grafana |
| Metrics Collection | Node Exporter, kube-state-metrics, Metrics Server |
| Source Control | Git, GitHub |

---

## 4. Infrastructure Provisioning with Terraform

Terraform is used to define and provision the AWS infrastructure required by the application platform.

### Infrastructure Components

- Amazon VPC networking.
- Public and private subnet configuration.
- Security groups and network access controls.
- Amazon EKS cluster.
- EKS managed node group.
- Supporting AWS infrastructure and IAM configuration.

### Infrastructure Workflow

```bash
terraform init

terraform fmt -recursive

terraform validate

terraform plan

terraform apply
```

Infrastructure changes are reviewed through Terraform plans before being applied.

---

## 5. CI/CD Pipeline with GitHub Actions

GitHub Actions automates the application build, security validation, container publishing, and Kubernetes deployment process.

### Pipeline Workflow

**1. Source Control**

- Application and infrastructure code are maintained in GitHub.
- Git commits provide version history and deployment traceability.
- Configured repository events trigger the CI/CD workflow.

**2. Security and Validation**

- Checkov performs infrastructure security checks.
- Trivy scans application filesystems and container images according to the configured workflow.
- Validation steps help identify issues before deployment.

**3. Docker Build**

- Build frontend and backend container images.
- Apply versioned image tags using Git commit SHA references.
- Prepare images for publishing.

**4. Amazon ECR Publishing**

- Authenticate to Amazon ECR.
- Push application images to private repositories.
- Maintain traceability between application commits and container images.

**5. Secure AWS Authentication**

- GitHub Actions uses OpenID Connect (OIDC) to assume an AWS IAM role.
- Avoids storing long-lived AWS access keys in GitHub repository secrets.
- IAM permissions are scoped to required deployment operations.

**6. Kubernetes Deployment**

- Connect to the Amazon EKS cluster.
- Verify access to the target namespace.
- Apply Kubernetes manifests with versioned image references.
- Validate application rollout status.

**7. Deployment Verification**

- Check Kubernetes pod readiness.
- Verify deployment rollout completion.
- Investigate failed scheduling and deployment events.

---

## 6. DevSecOps and Security Practices

Security is integrated into the infrastructure and application delivery workflow.

| Security Control | Implementation |
|---|---|
| Infrastructure Security | Checkov |
| Container Vulnerability Scanning | Trivy |
| AWS Authentication | GitHub Actions OIDC |
| Access Management | AWS IAM |
| Kubernetes Access | EKS Access Entries |
| Container Image Storage | Private Amazon ECR repositories |
| Network Security | VPC and Security Groups |
| Image Traceability | Git commit SHA-based tags |

### Security Engineering Objectives

- Avoid long-lived AWS credentials in CI/CD workflows.
- Apply least-privilege IAM permissions.
- Identify infrastructure misconfigurations.
- Scan container images for vulnerabilities.
- Restrict access to the EKS API endpoint.
- Maintain traceability between source code and deployed images.

---

## 7. Kubernetes Deployment and Troubleshooting

The application workloads are deployed to Amazon EKS in a dedicated namespace:

```bash
kubectl get pods -n three-tier-dev -o wide
```

### Deployment Verification

```bash
kubectl get deployments -n three-tier-dev

kubectl get services -n three-tier-dev

kubectl rollout status deployment/backend \
  -n three-tier-dev --timeout=120s

kubectl rollout status deployment/frontend \
  -n three-tier-dev --timeout=120s
```

### Practical Troubleshooting: Pod Scheduling Capacity

During a backend rolling update, a replacement pod encountered a scheduling failure because the existing worker node had reached its pod capacity.

**Root Cause**

The Kubernetes scheduler could not place the replacement backend pod on the existing worker node.

**Investigation**

```bash
kubectl get pods -n three-tier-dev -o wide

kubectl describe pod <pod-name> -n three-tier-dev

kubectl describe node <node-name>
```

The pod events identified the `Too many pods` scheduling issue.

**Resolution**

1. Inspected pod status and scheduling events.
2. Investigated node capacity using `kubectl describe node`.
3. Identified the worker-node pod capacity constraint.
4. Increased the EKS managed node group's desired capacity from one worker to two.
5. Verified that the replacement pod was scheduled on the additional worker.
6. Confirmed that the backend deployment rolled out successfully.
7. Reran GitHub Actions and verified successful workflow completion.

This exercise provided practical experience with Kubernetes scheduling, node capacity, rolling deployments, and workload recovery.

---

## 8. Monitoring and Observability

Prometheus and Grafana are deployed to the EKS cluster to monitor infrastructure metrics and provide visibility into worker-node resource utilization.

### Monitoring Components

| Component | Responsibility |
|---|---|
| Prometheus | Metrics collection and time-series storage |
| Grafana | Metrics visualization and dashboards |
| Node Exporter | Linux worker-node metrics |
| kube-state-metrics | Kubernetes resource and object-state metrics |
| Metrics Server | Kubernetes resource metrics |

### Monitoring Namespace

The monitoring components run in a dedicated namespace:

```bash
kubectl get pods -n monitoring
```

### Prometheus Verification

Prometheus is accessed through Kubernetes port forwarding:

```bash
kubectl port-forward -n monitoring \
  svc/prometheus-server 9090:80
```

Access the Prometheus interface:

```text
http://localhost:9090
```

The following PromQL query is used to verify whether monitored targets are available:

```promql
up
```

A value of `1` indicates that the corresponding target is successfully being scraped.

### Grafana Access

Grafana is accessed through Kubernetes port forwarding:

```bash
kubectl port-forward -n monitoring \
  svc/grafana 3000:80
```

Access Grafana:

```text
http://localhost:3000
```

Prometheus is configured as the Grafana data source.

### CPU Utilization Monitoring

The following PromQL query calculates worker-node CPU utilization as a percentage:

```promql
100 * (1 - avg by (instance) (
  rate(node_cpu_seconds_total{mode="idle"}[5m])
))
```

### Memory Utilization Monitoring

The following query calculates worker-node memory utilization as a percentage:

```promql
100 * (
  1 - (
    node_memory_MemAvailable_bytes
    /
    node_memory_MemTotal_bytes
  )
)
```

### Monitoring Objectives

- Observe CPU utilization across EKS worker nodes.
- Monitor available and used worker-node memory.
- Verify Prometheus target health.
- Visualize infrastructure metrics in Grafana.
- Identify potential resource pressure on Kubernetes nodes.

*Monitoring coverage and dashboard panels should be expanded as additional metrics and alerting capabilities are configured.*

---

## 9. Project Outcomes

The project demonstrates practical implementation and troubleshooting across several DevOps engineering areas.

### Cloud and Infrastructure

- Provisioned AWS infrastructure using Terraform.
- Deployed an Amazon EKS cluster.
- Configured worker-node capacity and networking.

### CI/CD and Automation

- Implemented automated GitHub Actions workflows.
- Built and published application Docker images.
- Integrated Amazon ECR.
- Implemented secure AWS authentication using OIDC.

### DevSecOps

- Integrated Checkov infrastructure security checks.
- Integrated Trivy security scanning.
- Applied IAM and Kubernetes access controls.

### Kubernetes Operations

- Deployed frontend, backend, and database workloads.
- Validated application rollouts.
- Investigated pod scheduling failures.
- Resolved worker-node pod capacity constraints.

### Observability

- Deployed Prometheus and Grafana.
- Configured Prometheus as a Grafana data source.
- Verified metrics collection from monitoring targets.
- Developed PromQL queries for CPU and memory monitoring.

---

## 10. Future Enhancements

The platform will be extended with additional production-oriented capabilities.

### Application Delivery and Networking

- Configure AWS Application Load Balancer integration.
- Enable HTTPS using AWS Certificate Manager (ACM).
- Configure Route 53 DNS and domain-based access.
- Introduce separate QA and production environments.

### Advanced DevSecOps

- Integrate Gitleaks for secret detection.
- Add SonarQube for static code analysis and quality gates.
- Generate Software Bills of Materials (SBOMs).
- Introduce image signing and artifact provenance.
- Strengthen automated testing and deployment rollback.

### Advanced Observability

- Configure Prometheus alerting and Alertmanager.
- Introduce centralized logging with Grafana Loki and Alloy.
- Add Kubernetes workload and application-level dashboards.
- Configure persistent storage for monitoring data.

### Secrets and Data Protection

- Integrate AWS Secrets Manager.
- Introduce External Secrets Operator.
- Implement MySQL persistent storage and backup procedures.
- Improve workload identity and access management.

---

## 11. Repository Structure

```text
.
├── .github/
│   └── workflows/
│       └── deploy.yml
├── k8s/
│   ├── backend.yaml
│   ├── frontend.yaml
│   └── ...
├── terraform/
│   └── ...
├── Dockerfile
└── README.md
```

*The structure above is illustrative; update it to reflect the actual repository contents.*

---

## 12. Key Engineering Lessons

Through this project, I developed practical experience in:

- AWS infrastructure provisioning and EKS operations.
- Terraform-based infrastructure management.
- Secure CI/CD automation with GitHub Actions.
- AWS IAM federation through GitHub OIDC.
- Docker image building and Amazon ECR.
- Kubernetes deployments and rollout management.
- Troubleshooting pod scheduling and node capacity.
- Prometheus metrics collection and Grafana visualization.
- PromQL for infrastructure resource monitoring.
- Integrating security and observability into application delivery.

---

## 13. Author

**Feezco Touch | DevOps Engineer**

- GitHub: https://github.com/Feezcodev
- Project Repository: https://github.com/Feezcodev/aws-3-tier-devops-platform

**Building secure, automated, and observable cloud infrastructure — one project at a time.**
