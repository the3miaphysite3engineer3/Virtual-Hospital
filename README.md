# Smart Hospital — On-Premises Deployment with Docker, MySQL, Grafana & phpMyAdmin

A **graduation-project-ready** smart hospital system deployed on a virtual machine on your laptop.  
No real server required — everything runs inside a VMware/VirtualBox VM using Docker.

---

## What's inside

| Component | Technology | Purpose |
|-----------|-----------|---------|
| Containerisation | Docker + Docker Compose | Run all services with one command |
| Database | MySQL 8.0 | Relational hospital database (5 tables) |
| Dashboard | Grafana 10 | Real-time analytics dashboard |
| DB Admin UI | phpMyAdmin | Web interface to browse/manage MySQL |
| Sample data | SQL seed scripts | 50 patients · 10 doctors · 80 appointments · billing |
| Analysis queries | `sql/queries.sql` | 20+ ready-to-use analytical SQL queries |

---

## Quick Start (inside the VM)

### Prerequisites
- Ubuntu Server 22.04 VM (8 GB RAM, 4 CPU, 60 GB disk)  
  → See [docs/vm-setup.md](docs/vm-setup.md) for step-by-step VM creation guide

### 1 — Clone the repo
```bash
git clone https://github.com/the3miaphysite3engineer3/Virtual-Hospital.git
cd Virtual-Hospital
```

### 2 — Run the setup script
```bash
bash scripts/setup.sh
```

This will automatically:
- Install Docker and Docker Compose
- Start MySQL (port **3307**), Grafana (port **3000**), and phpMyAdmin (port **8080**)
- Load the hospital schema and seed data
- Print the access URLs

### 3 — Open Grafana and phpMyAdmin
On your laptop browser, open:
```
http://<VM-IP>:3000
http://<VM-IP>:8080
```
- Grafana login: **admin / hospital_admin_2024**
- phpMyAdmin login: use MySQL credentials (for example `root` / `hospital_root_2024`)

---

## Manual startup (if Docker is already installed)

```bash
docker compose up -d          # start everything
docker compose logs -f        # watch logs
docker compose down           # stop everything
```

---

## MySQL quick access

```bash
docker compose exec mysql mysql -u root -phospital_root_2024 smart_hospital
```

Then paste any query from [`sql/queries.sql`](sql/queries.sql).

---

## Project structure

```
Virtual-Hospital/
├── docker-compose.yml              ← start the whole stack
├── sql/
│   ├── schema.sql                  ← database + table definitions
│   ├── seed_data.sql               ← sample hospital data
│   └── queries.sql                 ← 20+ analytical SQL queries
├── grafana/
│   ├── provisioning/
│   │   ├── datasources/mysql.yaml  ← auto-connect Grafana → MySQL
│   │   └── dashboards/dashboard.yaml
│   └── dashboards/
│       └── hospital-dashboard.json ← pre-built 14-panel dashboard
├── scripts/
│   └── setup.sh                    ← one-command installer
└── docs/
    ├── vm-setup.md                 ← step-by-step VM guide
    └── architecture.md             ← architecture diagram + design decisions
```

---

## Dashboard panels

The pre-built Grafana dashboard contains 14 panels:

| # | Panel | Type |
|---|-------|------|
| 1 | Total Patients | Stat |
| 2 | Total Doctors | Stat |
| 3 | Total Appointments | Stat |
| 4 | Total Revenue (EGP) | Stat |
| 5 | Total Treatments | Stat |
| 6 | Average Bill (EGP) | Stat |
| 7 | Monthly Appointments Trend | Time series |
| 8 | Monthly Revenue Trend | Time series |
| 9 | Top 10 Doctors by Appointments | Bar chart |
| 10 | Appointments by Status | Donut chart |
| 11 | Patient Gender Distribution | Pie chart |
| 12 | Most Common Treatment Types | Bar chart |
| 13 | Revenue by Doctor Specialization | Bar chart |
| 14 | Recent Appointments | Table |

---

## Credentials reference

| Service | URL | Username | Password |
|---------|-----|----------|----------|
| Grafana | http://\<VM-IP\>:3000 | admin | hospital_admin_2024 |
| phpMyAdmin | http://\<VM-IP\>:8080 | root or hospital_user | same MySQL password |
| MySQL root | localhost:3307 | root | hospital_root_2024 |
| MySQL app user | localhost:3307 | hospital_user | hospital_pass_2024 |

---

## Further reading

- [VM Setup Guide](docs/vm-setup.md) — how to create the VM from scratch
- [Architecture & Design Decisions](docs/architecture.md) — full architecture diagram, ER diagram, technology choices, and optional AWS Hybrid Cloud setup
