# Kargo auf Hetzner Cloud mit Talos OS

Test- und Evaluationsumgebung für Kargo (Continuous Promotion Orchestration) auf Hetzner Cloud mit Talos OS als Kubernetes-Plattform.

## Überblick

Dieses Repository enthält Infrastructure-as-Code für ein Multi-Stage Kubernetes Setup mit:

- **2 Environments**: Stage und Prod
- **Talos OS**: Immutable Kubernetes Platform
- **OpenTofu + Terragrunt**: Infrastructure as Code
- **Kargo + ArgoCD**: Continuous Promotion & GitOps
- **Hetzner Cloud**: Kosten-effiziente Cloud Infrastruktur (~€24/Monat)

## Architektur

```
┌─────────────────────────────────────────────────────────────┐
│                     Hetzner Cloud                           │
├─────────────────────────────────────────────────────────────┤
│  VPC Stage (10.1.0.0/16)      │  VPC Prod (10.2.0.0/16)    │
│  ┌─────────────────────────┐   │  ┌─────────────────────────┐│
│  │ Talos K8s 2-Node Cluster │   │  │ Talos K8s 2-Node Cluster ││
│  │ - 1 Control Plane       │   │  │ - 1 Control Plane       ││
│  │ - 1 Worker Node         │   │  │ - 1 Worker Node         ││
│  │ - Kargo + ArgoCD        │   │  │ - Applications          ││
│  └─────────────────────────┘   │  └─────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
```

## Struktur

```
.
├── catalog/modules/          # Wiederverwendbare OpenTofu Module
│   ├── networking/           # VPC, Firewall, Floating IPs
│   └── talos-cluster/        # Talos Kubernetes Cluster
├── live/                     # Terragrunt Environment Konfigurationen
│   ├── root.hcl              # Globale Provider & Backend Config
│   ├── stage/                # Stage Environment
│   │   ├── networking/
│   │   └── cluster/
│   └── prod/                 # Prod Environment
│       ├── networking/
│       └── cluster/
├── Taskfile.yml              # Vereinfachte Commands
└── .env                      # Environment Variables (nicht einchecken!)
```

## Voraussetzungen

- [OpenTofu](https://opentofu.org/) >= 1.9.0
- [Terragrunt](https://terragrunt.gruntwork.io/) >= 0.56.0
- [Task](https://taskfile.dev/)
- Hetzner Cloud Account + API Token
- Hetzner Object Storage Bucket (für Remote State)

## Setup

### 1. Credentials konfigurieren

```bash
cp .env.example .env
```

`.env` bearbeiten:

```
HETZNER_API_TOKEN=your_hetzner_api_token
AWS_ACCESS_KEY_ID=your_s3_access_key
AWS_SECRET_ACCESS_KEY=your_s3_secret_key
```

### 2. Infrastruktur deployen

```bash
# Stage Environment
task tg:plan ENV=stage    # Plan anzeigen
task tg:apply ENV=stage   # Deploy

# Oder ohne Task:
cd live/stage
terragrunt run-all apply
```

### 3. Kubeconfig abrufen

```bash
talosctl kubeconfig --nodes <controlplane-ip> --endpoints <api-endpoint>
```

## Commands

| Command                                       | Beschreibung                  |
| --------------------------------------------- | ----------------------------- |
| `task tg:plan ENV=stage`                      | Plan für Environment anzeigen |
| `task tg:apply ENV=stage`                     | Environment deployen          |
| `task tg:destroy ENV=stage`                   | Environment zerstören         |
| `task tg:plan-unit ENV=stage UNIT=networking` | Einzelne Unit planen          |
| `task clean`                                  | Generierte Dateien aufräumen  |

## Netzwerk-Design

### Stage

- **Network**: 10.1.0.0/16
- **Subnet**: 10.1.1.0/24
- **Control Plane**: 10.1.1.100
- **Worker**: 10.1.1.101

### Prod

- **Network**: 10.2.0.0/16
- **Subnet**: 10.2.1.0/24
- **Control Plane**: 10.2.1.100
- **Worker**: 10.2.1.101

## Kosten

- **Stage**: 2x CPX11 (~€8/Monat)
- **Prod**: 2x CPX21 (~€16/Monat)
- **Gesamt**: ~€24/Monat

## Technologien

- **Talos OS** v1.12.6 - Immutable Kubernetes
- **Kubernetes** v1.32.13
- **Kargo** - Continuous Promotion Orchestration
- **ArgoCD** - GitOps Deployment
- **Traefik** - Ingress Controller
- **Cert-Manager** - TLS Zertifikate

## Dokumentation

- [PLANNING.md](PLANNING.md) - Detaillierte Projektplanung
- [AGENTS.md](AGENTS.md) - Information für AI Agents

## Hinweise

- Remote State ist in Hetzner Object Storage konfiguriert
- Keine Load Balancer - Floating IPs für API Server
