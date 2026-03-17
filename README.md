# Kubernetes Cluster on AWS — Terraform

Simple two-node Kubernetes cluster (1 master + 1 worker) on AWS using Terraform.

---

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) ~> 1.14
- AWS CLI configured (`aws configure`)
- SSH key pair generated

### Generate SSH Key
```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/aws-k8s/k8s-key
```

---

## Project Structure
```
kube-in-aws/
├── .gitignore
├── data.tf                  # AMI data source
├── instance.tf              # EC2 instances & key pair
├── locals.tf                # Common tags
├── networking.tf            # VPC, subnet, IGW, route table
├── output.tf                # Output values
├── provider.tf              # Terraform & AWS provider config
├── security-group.tf        # Security group rules
├── variables.tf             # Variable declarations
├── terraform.tfvars         # Your values (You must create it)
└── README.md
```

---

## Variables

Create a `terraform.tfvars` file in the project root (never commit this file):
```hcl
aws_region         = "eu-west-1"        # AWS region
instance_type      = "t3.micro"         # EC2 instance type
instance_count     = 2                  # Number of nodes (1 master + 1 worker)
vpc_cidr_block     = "172.16.0.0/16"   # VPC CIDR
public_subnet_cidr = "172.16.10.0/24"  # Subnet CIDR
my_ip              = "0.0.0.0/0"       # SSH access — use x.x.x.x/32 to restrict to your IP
```

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `aws_region` | string | `eu-west-1` | AWS region to deploy resources |
| `instance_type` | string | `t3.micro` | EC2 instance type |
| `instance_count` | number | `2` | Number of Kubernetes nodes |
| `vpc_cidr_block` | string | `172.16.0.0/16` | CIDR block for the VPC |
| `public_subnet_cidr` | string | `172.16.10.0/24` | CIDR block for the public subnet |
| `my_ip` | string | `0.0.0.0/0` | IP CIDR allowed for SSH and K8s API access |

---

## Usage

### 1. Initialize
```bash
terraform init
```

### 2. Plan
```bash
terraform plan
```

### 3. Apply
```bash
terraform apply
```

After apply, outputs will show public IPs:
```
master_public_ip = "x.x.x.x"
node_public_ips  = ["x.x.x.x", "x.x.x.x"]
```

### 4. SSH into nodes
```bash
# Master
ssh -i ~/.ssh/aws-k8s/k8s-key ubuntu@<master-public-ip>

# Worker
ssh -i ~/.ssh/aws-k8s/k8s-key ubuntu@<worker-public-ip>
```

### 5. Stop (save money, keep data)
```bash
aws ec2 stop-instances --instance-ids i-xxx i-xxx
```
> ⚠️ Public IP doesn't change on restart, we are using Elastic IP.

### 6. Start back
```bash
aws ec2 start-instances --instance-ids i-xxx i-xxx
terraform output  # check new IPs
```

### 7. Destroy (complete delete, zero cost)
```bash
terraform destroy
```
> Everything is deleted — instances, IPs, VPC. No leftover charges.

---

## Costs (eu-west-1)

| Resource | Running | Stopped |
|----------|---------|---------|
| t3.micro (x2) | ~$0.02/hr | $0.00 |
| EBS 10GB gp3 (x2) | ~$0.08/mo | ~$0.08/mo |
| Elastic IP (x2) | free | ~$0.005/hr each |

> 💡 Use `terraform destroy` if not using for more than a day — it's cheaper than leaving stopped instances with Elastic IPs.

---

## Ports Open

| Port | Protocol | Purpose |
|------|----------|---------|
| 22 | TCP | SSH access |
| 6443 | TCP | Kubernetes API server |
| all | all | Internal node communication |