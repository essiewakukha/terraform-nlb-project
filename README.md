# AWS Network Load Balancer (NLB) + Nginx on EC2 — Terraform

> **DOP-C02 Domain 1 Practice Project** — Infrastructure as Code with Terraform

## Architecture

```
Client Browser
      │
      ▼  TCP :80
┌─────────────────────────────────────┐
│  Network Load Balancer (Layer 4)    │
│  nlb-nginx-demo-nlb                 │
└───────────────┬─────────────────────┘
                │ Round-robin TCP
       ┌────────┴────────┐
       ▼                 ▼
  ┌─────────┐       ┌─────────┐
  │  EC2-1  │       │  EC2-2  │
  │  Nginx  │       │  Nginx  │
  │  AZ1    │       │  AZ2    │
  └─────────┘       └─────────┘
       │                 │
       └────────┬────────┘
                ▼
        Target Group (NLB-TG)
         TCP health check :80
```

### What gets created
| Resource | Details |
|----------|---------|
| VPC | 10.0.0.0/16, DNS enabled |
| Public Subnet 1 | 10.0.1.0/24 — AZ1 |
| Public Subnet 2 | 10.0.2.0/24 — AZ2 |
| Internet Gateway | Routes VPC → internet |
| Route Table | 0.0.0.0/0 → IGW |
| Security Group | Port 80 (all), Port 22 (your IP) |
| EC2 Instance 1 | Amazon Linux 2023, t2.micro + Nginx |
| EC2 Instance 2 | Amazon Linux 2023, t2.micro + Nginx |
| Network Load Balancer | Internet-facing, TCP Layer 4 |
| Target Group | TCP:80, health check every 30s |
| NLB Listener | TCP:80 → forwards to Target Group |

---

## Prerequisites

1. **AWS CLI configured** — run `aws configure` with your Access Key ID, Secret Key, and region
2. **Terraform installed** — [download here](https://developer.hashicorp.com/terraform/downloads)
3. **An EC2 Key Pair** (optional, for SSH access) — create one in EC2 Console → Key Pairs

---

## Quick Start

### 1. Clone / download the project
```bash
git clone <your-repo-url>
cd terraform-nlb
```

### 2. (Optional) Create a `terraform.tfvars` file to customise
```hcl
# terraform.tfvars
aws_region   = "us-east-1"
project_name = "nlb-nginx-demo"
your_ip      = "203.0.113.10/32"   # Your public IP — get it at https://checkip.amazonaws.com
key_name     = "my-keypair"         # Existing EC2 key pair name (leave "" to skip SSH)
```

> ⚠️ **Security tip:** Always restrict `your_ip` to your real IP address in production. `0.0.0.0/0` opens SSH to the whole internet.

### 3. Initialise Terraform
```bash
terraform init
```

### 4. Preview the plan
```bash
terraform plan
```

### 5. Deploy
```bash
terraform apply
```
Type `yes` when prompted. Deployment takes ~2–3 minutes.

### 6. Test
After apply completes, the NLB DNS name is printed:
```
Outputs:
nlb_dns_name = "http://nlb-nginx-demo-nlb-xxxxxxxxxx.elb.amazonaws.com"
```

Open that URL in your browser. **Refresh several times** — you'll see the page alternate between **Instance 1 (AZ1)** and **Instance 2 (AZ2)** as the NLB round-robins between them.

> ⏱️ Note: It may take 1–2 minutes after `apply` for the instances to boot, Nginx to install, and health checks to pass.

---

## Clean Up (Avoid AWS charges!)

```bash
terraform destroy
```
Type `yes`. This deletes everything Terraform created.

---

## Key Concepts — DOP-C02 Reference

| Concept | This Project |
|---------|-------------|
| NLB vs ALB | NLB = Layer 4 (TCP). ALB = Layer 7 (HTTP/HTTPS). NLB is faster, lower latency |
| Target Groups | NLB routes to target group; health checks decide which targets are healthy |
| Cross-zone LB | `enable_cross_zone_load_balancing = true` — distributes evenly across all AZs |
| User Data | Bootstrap script runs once on first boot — installs and starts Nginx |
| IaC benefits | Reproducible, version-controlled, no manual clicks in console |
| Idempotency | Run `terraform apply` again — it only changes what's different |

---

## File Structure

```
terraform-nlb/
├── main.tf            # VPC, subnets, IGW, route tables
├── ec2.tf             # EC2 instances + Nginx user_data
├── nlb.tf             # NLB, target group, listener, attachments
├── security-groups.tf # EC2 security group (port 80, 22)
├── variables.tf       # All configurable variables
├── outputs.tf         # NLB DNS name, instance IPs, etc.
└── README.md          # This file
```

---

## Troubleshooting

**NLB URL returns nothing / connection refused**
- Wait 2–3 minutes after `apply` — Nginx is still installing
- Check EC2 Console → Instances → Instance State = "running"
- Check Target Group → Targets → Health Status = "healthy"

**SSH not working**
- Ensure `key_name` matches an existing EC2 key pair in your AWS account
- Ensure `your_ip` is set to your correct IP (`curl https://checkip.amazonaws.com`)

**`Error: No valid credential sources`**
- Run `aws configure` to set up AWS credentials