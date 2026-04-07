# Architecture — Smart Hospital On-Prem with Hybrid Cloud

## Overview

The Smart Hospital system uses an **on-premises virtualization** model, with an optional
**Hybrid Cloud** extension to AWS for backup and disaster recovery.

```
┌──────────────────────────────────────────────────────────┐
│  Laptop (16 GB RAM)                                      │
│                                                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │  VMware Workstation Player                       │   │
│  │                                                  │   │
│  │  ┌────────────────────────────────────────────┐  │   │
│  │  │  Ubuntu Server 22.04 VM                    │  │   │
│  │  │  (8 GB RAM · 4 CPU · 60 GB disk)           │  │   │
│  │  │                                            │  │   │
│  │  │  ┌──────────────────────────────────────┐  │  │   │
│  │  │  │  Docker Engine                       │  │  │   │
│  │  │  │                                      │  │  │   │
│  │  │  │  ┌─────────────┐  ┌───────────────┐  │  │  │   │
│  │  │  │  │  MySQL 8.0  │  │  Grafana 10   │  │  │  │   │
│  │  │  │  │  :3306      │  │  :3000        │  │  │  │   │
│  │  │  │  │             │  │               │  │  │  │   │
│  │  │  │  │  smart_     │◄─┤  Dashboards   │  │  │  │   │
│  │  │  │  │  hospital   │  │  & Alerts     │  │  │  │   │
│  │  │  │  │  database   │  │               │  │  │  │   │
│  │  │  │  └─────────────┘  └───────────────┘  │  │  │   │
│  │  │  │                                      │  │  │   │
│  │  │  │  Named volumes:                      │  │  │   │
│  │  │  │    mysql_data   (persistent DB)      │  │  │   │
│  │  │  │    grafana_data (dashboards/config)  │  │  │   │
│  │  │  └──────────────────────────────────────┘  │  │   │
│  │  └────────────────────────────────────────────┘  │   │
│  └──────────────────────────────────────────────────┘   │
│                                                          │
│  Browser on Laptop ──► http://<VM-IP>:3000 (Grafana)   │
└──────────────────────────────────────────────────────────┘
                          │
                    Internet (optional)
                          │
              ┌───────────▼───────────┐
              │  AWS Cloud (Hybrid)   │
              │                       │
              │  S3 — DB backup       │
              │  RDS — Cloud replica  │
              │  EC2 — Remote access  │
              └───────────────────────┘
```

---

## Technology Choices

### Virtual Machine — VMware Workstation Player
- Works perfectly on laptops
- Supports 64-bit guests, hardware virtualisation (VT-x)
- Better performance than VirtualBox for disk I/O
- Free for personal/education use

### Guest OS — Ubuntu Server 22.04 LTS
- Lightweight (no desktop environment needed)
- Long-term support until 2027
- Excellent Docker and MySQL compatibility
- Used by major hospitals and cloud providers

### Container Engine — Docker + Docker Compose
- Eliminates "works on my machine" problems
- One command to start the entire stack (`docker compose up -d`)
- Easy version upgrades and rollback
- Industry standard for modern on-prem deployments

### Database — MySQL 8.0
- Most widely used open-source relational database
- Native CSV import (`LOAD DATA INFILE`)
- Excellent Grafana connector
- Perfect for hospital relational schemas (patients, appointments, billing)
- ACID-compliant — data integrity guaranteed

### Dashboard — Grafana 10
- Open-source, no licence cost
- Native MySQL data source (no extra plugins)
- Real-time auto-refresh
- Professional look for presentations
- Runs entirely inside the VM — no internet required

### Storage Model — Docker Named Volumes (On-Prem)
- `mysql_data` volume → survives container restarts
- Stored inside the VM disk (60 GB)
- Acts exactly like a hospital on-premises storage server
- Can be backed up with `docker run --volumes-from ... tar`

---

## Database Schema (Entity Relationship)

```
patients ─────┐
              ├──► appointments ──► treatments
doctors  ─────┘         │
                         └──────► billing
```

| Table        | Key columns |
|--------------|-------------|
| patients     | patient_id (PK), first_name, last_name, gender, date_of_birth, insurance_provider |
| doctors      | doctor_id (PK), first_name, last_name, specialization, years_experience |
| appointments | appointment_id (PK), patient_id (FK), doctor_id (FK), appointment_date, status |
| treatments   | treatment_id (PK), appointment_id (FK), treatment_type, diagnosis, medications |
| billing      | billing_id (PK), patient_id (FK), appointment_id (FK), billing_amount, payment_status |

---

## Port Reference

| Service | Container Port | Host Port | URL |
|---------|---------------|-----------|-----|
| MySQL   | 3306          | 3307      | mysql://localhost:3307 |
| Grafana | 3000          | 3000      | http://localhost:3000  |
| phpMyAdmin | 80         | 8080      | http://localhost:8080  |

---

## Hybrid Cloud Extension (Optional)

To connect the on-prem VM to AWS:

### Step 1 — Create AWS account (free tier)
Go to https://aws.amazon.com/free/

### Step 2 — Create S3 bucket for backup
```bash
# Install AWS CLI inside the VM
sudo apt install awscli -y
aws configure   # enter your Access Key ID and Secret

# Backup the MySQL data volume to S3
docker exec hospital-mysql mysqldump -u root -phospital_root_2024 smart_hospital \
  | gzip | aws s3 cp - s3://your-bucket-name/hospital-backup-$(date +%F).sql.gz
```

### Step 3 — Automate daily backups with cron
```bash
crontab -e
# Add this line (backup every day at 2 AM):
0 2 * * * docker exec hospital-mysql mysqldump -u root -phospital_root_2024 smart_hospital | gzip | aws s3 cp - s3://your-bucket-name/hospital-backup-$(date +\%F).sql.gz
```

### Architecture description for your presentation
> "The Smart Hospital system is deployed on an on-premises virtual server running inside a VMware VM.
> The MySQL database and Grafana dashboard run as Docker containers for portability and ease of deployment.
> The system is connected to AWS S3 through the internet, providing daily encrypted backups and
> disaster-recovery capability. This **Hybrid Cloud** architecture balances data sovereignty (local
> storage for sensitive patient data) with cloud resilience (offsite backup)."
