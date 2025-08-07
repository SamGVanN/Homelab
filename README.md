# 🏡 Homelab Repository

Welcome to my Homelab repository — a space to centralize scripts, tutorials, configurations, and tools powering my personal server setup.

---

## 🖥️ Hardware & System

This server runs on an **old desktop tower** I repurposed for self-hosting.

- **OS**: Ubuntu Server (headless)
- **Firewall**: [UFW](https://wiki.ubuntu.com/UncomplicatedFirewall) enabled and configured
- **Remote Access**: via **WireGuard** VPN set up on my **Freebox**
- **Backups**: custom script backing up to an **external hard drive** (a dedicated `/DATA` disk is planned)

---

## ⚙️ Core Services & Tools

Here are the main services currently running:

| Category          | Tools / Software                                                                   |
|-------------------|-------------------------------------------------------------------------------------|
| **Networking**     | [Pi-hole](https://pi-hole.net/) – DNS-based ad blocking                           |
| **Web Interface**  | [CasaOS](https://www.casaos.io/) – Simple UI for managing containers               |
| **Reverse Proxy**  | [Nginx Proxy Manager](https://nginxproxymanager.com/) – External access management |
| **Streaming Stack**| Prowlarr, Radarr, Sonarr, Bazarr, Jellyfin, Jellyseer                                                |
| **Downloads**      | [qBittorrent](https://www.qbittorrent.org/), [SABnzbd](https://sabnzbd.org/)       |
| **Recipes**        | [Mealie](https://hay-kot.github.io/mealie/) – Recipe manager                      |
| **Documents**      | [Paperless-ngx](https://github.com/paperless-ngx/paperless-ngx) – Digital archiving|

---

## 📡 Features

- **Headless** server accessed via SSH and CasaOS interface
- Local DNS filtering with **Pi-hole**
- Secure remote access using **WireGuard**
- Hosting media, utilities, and personal services
- Active firewall with **UFW**
- Manual backup system (automation planned)

---

## 📈 Scalability

This server is designed to grow with my needs. New services will be added over time, and the infrastructure will evolve accordingly.

---

## 📦 Backup Strategy

**Current setup:**
- Manual script triggered on demand
- Backups stored on an external hard drive

**Planned improvements:**
- Dedicated `/DATA` disk for:
  - Automated backups
  - Centralized media storage (movies, series, etc.)

---

## 🛠️ About This Repository

This repo includes (or will include):
- Configuration scripts
- Installation guides
- Technical notes
- Service setup files

---

## 📬 Contact

This is a personal project, but I'm always open to feedback or discussion around self-hosting and homelabs. Feel free to open an issue or reach out!
