# VM Setup Guide — Smart Hospital On-Prem Deployment

This guide walks you through setting up a virtual machine (VM) on your laptop and deploying the Smart Hospital system from scratch.

---

## Part 1 — Install VMware Workstation Player

1. Go to **https://www.vmware.com/products/workstation-player.html**
2. Download **VMware Workstation Player** (free for personal/education use).
3. Run the installer → click **Next → Next → Finish**.

> **Alternative**: VirtualBox is also free — https://www.virtualbox.org

---

## Part 2 — Download Ubuntu Server 22.04

1. Go to **https://ubuntu.com/download/server**
2. Download `ubuntu-22.04-live-server-amd64.iso` (~1.5 GB).

---

## Part 3 — Create the Virtual Machine

Open VMware Workstation Player → **Create a New Virtual Machine**

| Setting          | Recommended value (16 GB laptop)        |
|------------------|-----------------------------------------|
| RAM              | **8 GB** (8192 MB)                      |
| CPU cores        | **4**                                   |
| Disk size        | **60 GB** (store on SSD if possible)    |
| Operating System | **Ubuntu 64-bit**                       |
| ISO file         | point to the `.iso` you downloaded      |

Click **Finish** and start the VM.

---

## Part 4 — Install Ubuntu Server Inside the VM

1. Boot the VM — the Ubuntu installer starts automatically.
2. Choose language: **English**.
3. Select **Install Ubuntu Server**.
4. Network: leave default (DHCP) — press **Done**.
5. Storage: leave default (use entire disk) — press **Done → Continue**.
6. Create a user account (remember the password!).
7. **Enable OpenSSH server** — tick the checkbox, press **Done**.
8. Wait ~10 minutes → reboot when prompted.

---

## Part 5 — Log In and Update the System

```bash
# Log in with the username/password you chose
sudo apt update && sudo apt upgrade -y
```

---

## Part 6 — Install Git and Clone the Project

```bash
sudo apt install git -y
git clone https://github.com/the3miaphysite3engineer3/Virtual-Hospital.git
cd Virtual-Hospital
```

---

## Part 7 — Run the Setup Script (installs Docker automatically)

```bash
bash scripts/setup.sh
```

The script will:
- Install Docker + Docker Compose
- Start PostgreSQL, Grafana, and pgAdmin containers
- Load the hospital schema and sample data automatically
- Print the access URL when done

---

## Part 8 — Access Grafana from Your Laptop

After the script finishes, it prints something like:

```
Grafana Dashboard : http://192.168.x.x:3000
```

Open that URL in your laptop browser (VMware creates a bridged/NAT network so your laptop can reach the VM).

Login: **admin / hospital_admin_2024**

For pgAdmin, open:

```
http://<VM-IP>:8080
```

Login: **admin@hospital.local / hospital_pgadmin_2024**

---

## Part 9 — Access PostgreSQL Directly (optional)

```bash
# From inside the VM:
docker compose exec postgres psql -U hospital_user -d smart_hospital
```

Then run any query from `sql/queries.sql`.

---

## Part 10 — Stop / Restart Everything

```bash
# Stop all containers
docker compose down

# Start again
docker compose up -d

# View real-time logs
docker compose logs -f
```

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Can't reach port 3000 from laptop | In VMware, set network to **Bridged** mode |
| Docker permission denied | Run `newgrp docker` or log out and log in again |
| PostgreSQL container keeps restarting | Run `docker compose logs postgres` to see the error |
| Grafana shows "No data" | Wait 30 s for PostgreSQL to finish loading seed data, then refresh |
