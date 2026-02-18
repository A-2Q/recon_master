# 🔍 ReconMaster

> **Comprehensive Reconnaissance Script for Kali Linux**  
> Automated, multi-phase recon tool for authorized penetration testing.

![Bash](https://img.shields.io/badge/Shell-Bash-green?style=flat-square&logo=gnu-bash)
![Platform](https://img.shields.io/badge/Platform-Kali%20Linux-blue?style=flat-square&logo=kali-linux)
![License](https://img.shields.io/badge/License-Apache%202.0-red?style=flat-square)
![Version](https://img.shields.io/badge/Version-2.0-yellow?style=flat-square)

---

## ⚠️ Legal Disclaimer

> This tool is intended **only** for authorized security assessments, CTF challenges, and systems you own.  
> Unauthorized use against systems without explicit permission is **illegal**.  
> The author assumes **no responsibility** for misuse.

---

## 📋 Table of Contents

- [Features](#-features)
- [Requirements](#-requirements)
- [Installation](#-installation)
- [Usage](#-usage)
- [Scan Phases](#-scan-phases)
- [Output Preview](#-output-preview)
- [License](#-license)

---

## ✨ Features

- 🌐 **WHOIS & DNS Enumeration** — Full domain ownership and record analysis
- 🔎 **Subdomain Discovery** — subfinder + DNS brute-force + crt.sh transparency logs
- 🔍 **Deep Port Scanning** — nmap with service/version detection and OS fingerprinting
- 🌍 **Web Analysis** — HTTP security headers audit + technology stack fingerprinting (WhatWeb)
- 🔒 **SSL/TLS Inspection** — Certificate validity, expiry, SAN names, TLS version check
- 🤖 **robots.txt / sitemap.xml** — Sensitive path discovery
- 💣 **Directory Fuzzing** — feroxbuster with Kali built-in wordlists
- 🎯 **Parameter Fuzzing** — wfuzz + quick LFI probe
- 🎨 **Beautiful Terminal Output** — ANSI colors, ASCII tables, live progress bar

---

## 🛠 Requirements

### Required Tools
| Tool | Install |
|------|---------|
| `nmap` | `sudo apt install nmap -y` |
| `whois` | `sudo apt install whois -y` |
| `dig` | `sudo apt install dnsutils -y` |
| `curl` | `sudo apt install curl -y` |
| `whatweb` | `sudo apt install whatweb -y` |
| `ffuf` | `sudo apt install ffuf -y` |
| `feroxbuster` | `sudo apt install feroxbuster -y` |
| `wfuzz` | `sudo apt install wfuzz -y` |
| `openssl` | `sudo apt install openssl -y` |
| `subfinder` | `go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest` |

### Recommended Wordlists
```bash
sudo apt install seclists -y
```

---

## 📦 Installation

```bash
# Clone the repository
git clone https://github.com/A-2Q/recon_master.git
cd recon_master

# Make executable
chmod +x recon_master.sh
```

---

## 🚀 Usage

```bash
sudo bash recon_master.sh <domain_or_IP>
```

**Examples:**
```bash
sudo bash recon_master.sh example.com
sudo bash recon_master.sh 192.168.1.1
sudo bash recon_master.sh target.htb
```

> ℹ️ Run as **root** (`sudo`) for full nmap OS detection capabilities.

---

## 🗺 Scan Phases

| # | Phase | Description | Tools Used |
|---|-------|-------------|------------|
| 1A | WHOIS Lookup | Registrar, org, country, expiry | `whois` |
| 1B | DNS Records | A, MX, NS, TXT, SOA + Zone Transfer | `dig` |
| 1C | Subdomain Enum | Active + passive subdomain discovery | `subfinder`, `crt.sh` |
| 2 | Port Scanning | All ports, service versions, OS detection | `nmap -sV -sC -O -p-` |
| 3 | Web Analysis | Security headers + tech stack fingerprint | `curl`, `whatweb` |
| 4 | SSL/TLS Check | Certificate info, expiry, TLS version | `openssl` |
| 5 | Robots/Sitemap | Sensitive path exposure check | `curl` |
| 6 | Dir Fuzzing | Hidden directories and files | `feroxbuster` |
| 7 | Param Fuzzing | GET parameter discovery + LFI probe | `wfuzz` |

---

## 🖥 Output Preview

```
  ██████╗ ███████╗ ██████╗ ██████╗ ███╗   ██╗    ███╗   ███╗  █████╗ ███████╗████████╗███████╗██████╗
  ...

  Progress: [████████████████░░░░░░░░░░░░░░░░░░░░░░░░] 44%  →  Port Scanning

  ╔══════════════════════════════════════════════════════════════════╗
  ║  PORT     STATE    SERVICE    VERSION                           ║
  ╠══════════════════════════════════════════════════════════════════╣
  ║  80/tcp   open     http       Apache httpd 2.4.51               ║
  ║  443/tcp  open     https      nginx 1.21.0                      ║
  ║  22/tcp   open     ssh        OpenSSH 8.4p1                     ║
  ╚══════════════════════════════════════════════════════════════════╝
```

---

## 📁 Project Structure

```
recon_master/
├── recon_master.sh     # Main script
├── README.md           # This file
├── LICENSE             # Apache 2.0 License
└── .gitignore          # Git ignore rules
```

---

## 🤝 Contributing

Pull requests are welcome. For major changes, please open an issue first.

---

## 📄 License

Copyright 2024 **A_2Q**

Licensed under the [Apache License 2.0](LICENSE).
