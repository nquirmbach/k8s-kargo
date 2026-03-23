# Kargo auf Hetzner Cloud mit Talos OS - Projektplanung

## Projektziel

Test- und Evaluationsumgebung für Kargo (Continuous Promotion Orchestration) auf Hetzner Cloud mit Talos OS als Kubernetes-Plattform. Das Setup besteht aus zwei Umgebungen (Stage & Prod) zur Demonstration von Multi-Stage GitOps Deployments.

## Architektur

### Gesamt-Übersicht

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

### Technologien & Komponenten

#### Infrastruktur

- **OpenTofu** v1.9.0+ für Infrastructure as Code
- **Terragrunt** v0.56.0+ für Configuration Management
- **Hetzner Cloud** als Cloud Provider
- **Talos OS** v1.13.0+ für Kubernetes Nodes (immutable, secure)
- **Hetzner Cloud Controller Manager** v1.21.0+ für Cloud Integration
- **Hetzner CSI** v2.7.0+ für persistent Storage

#### Kubernetes Ökosystem

- **Talos OS** v1.12.6+ (Latest Stable)
- **Kubernetes** v1.32.13+ (Latest Stable)
- **Kargo** v1.1.0+ für Continuous Promotion
- **ArgoCD** v2.13.0+ für GitOps Deployment
- **Cert-Manager** v1.16.0+ für TLS Zertifikate
- **Traefik v3** mit **Gateway API** für Ingress

#### Networking & Security

- **Private Networks** pro Environment
- **Hetzner Load Balancer** für API Server & Ingress
- **Firewall** Rules pro Environment
- **WireGuard VPN** für Management Access (optional)
- **API Gateway** (Optional) statt/ergänzend zu Ingress

## VPC Design

### Stage Environment

- **Network CIDR**: `10.1.0.0/16`
- **Subnet**: `10.1.1.0/24`
- **Load Balancer IP**: `10.1.1.10`
- **API Server IP**: `10.1.1.11`
- **Node IP Range**: `10.1.1.100-10.1.1.200`

### Prod Environment

- **Network CIDR**: `10.2.0.0/16`
- **Subnet**: `10.2.1.0/24`
- **Load Balancer IP**: `10.2.1.10`
- **API Server IP**: `10.2.1.11`
- **Node IP Range**: `10.2.1.100-10.2.1.200`

## Node-Konfiguration & Kosten

### Stage Environment (~€15-20/Monat)

- **Control Plane**: 1x CPX11 (2 vCPU, 4 GB RAM, 40 GB SSD) - Single Node
- **Worker Nodes**: 1x CPX11 (2 vCPU, 4 GB RAM, 40 GB SSD) - Single Worker
- **Storage**: Lokaler SSD Storage
- **Load Balancer**: Keiner (direkter Node Access via Floating IP)

### Prod Environment (~€15-20/Monat)

- **Control Plane**: 1x CPX21 (2 vCPU, 4 GB RAM, 40 GB SSD) - Single Node
- **Worker Nodes**: 1x CPX21 (2 vCPU, 4 GB RAM, 40 GB SSD) - Single Worker
- **Storage**: Lokaler SSD Storage + 1x Volume (50 GB)
- **Load Balancer**: Keiner (Floating IP für API Server, NodePort für Services)

**Gesamtkosten: ~€23-28/Monat**

## Security-Konzept

### Network Security

1. **Network Isolation**: Separate VPCs pro Environment
2. **Private Networking**: Internes Traffic ausschließlich über Private Netze
3. **Firewall Rules**:
   - API Server: 6443 nur von Management IPs
   - Kubelet: 10250 nur innerhalb Cluster
   - etcd: 2379-2380 nur zwischen Control Planes
   - Ingress: 80/443 von Internet

### Access Management

1. **Bastion Host**: Optional für SSH Access
2. **WireGuard VPN**: Für sicheren Management Zugriff
3. **RBAC**: Kubernetes RBAC für Cluster Access
4. **API Tokens**: Hetzner API Token mit minimalen Permissions

### Secrets Management

- **Hetzner Secrets** oder **SOPS** für Secrets
- **GitOps-freundlich**: Verschlüsselte Secrets in Git

## Projektstruktur

```
k8s-kargo/
├── catalog/                       # Reusable OpenTofu Module
│   └── modules/
│       ├── networking/            # VPC, Firewall, Floating IPs
│       │   ├── main.tf
│       │   ├── variables.tf
│       │   ├── outputs.tf
│       │   └── versions.tf
│       └── talos-cluster/         # Talos Kubernetes Cluster
│           ├── main.tf
│           ├── variables.tf
│           ├── outputs.tf
│           └── versions.tf
├── live/                          # Terragrunt Environment Konfigurationen
│   ├── root.hcl                   # Globale Provider & Backend Config
│   ├── stage/                     # Stage Environment
│   │   ├── terragrunt.hcl
│   │   ├── networking/
│   │   │   └── terragrunt.hcl
│   │   └── cluster/
│   │       └── terragrunt.hcl
│   └── prod/                      # Prod Environment
│       ├── terragrunt.hcl
│       ├── networking/
│       │   └── terragrunt.hcl
│       └── cluster/
│           └── terragrunt.hcl
├── kargo/                         # Kargo Manifeste & Konfigurationen
│   ├── manifests/
│   ├── argocd-apps/
│   └── examples/
├── scripts/                       # Hilfsskripte
├── docs/                          # Dokumentation
├── Taskfile.yml                   # Task Runner Konfiguration
├── PLANNING.md                    # Diese Datei
├── AGENTS.md                      # Information für AI Agents
└── README.md
```

### Verzeichnis-Struktur Erklärung

- **`catalog/modules/`** - Reine OpenTofu Module (`.tf` Dateien)
  - Enthalten die eigentliche Infrastruktur-Logik
  - Environment-unabhängig, wiederverwendbar
  - Werden von Terragrunt referenziert

- **`live/`** - Terragrunt Environment Konfigurationen (`.hcl` Dateien)
  - `root.hcl` - Globale Provider Konfiguration (Hetzner)
  - `stage/` und `prod/` - Environment-spezifische Konfigurationen
  - Jede Unit (networking, cluster) hat eigene `terragrunt.hcl`
  - Dependencies werden automatisch aufgelöst

- **`Taskfile.yml`** - Vereinfachte Commands
  - `task tg:plan ENV=stage` - Plan für Environment
  - `task tg:apply ENV=stage` - Deploy Environment
  - `task tg:destroy ENV=stage` - Destroy Environment

## Implementierungs-Phasen

### Phase 1: Vorbereitung

- [x] Hetzner Account & API Token
- [ ] Domain für Ingress konfigurieren (oder nip.io für Test-Setup)
- [x] SSH Keys erstellen
- [x] Git Repository für Kargo Manifeste (im selben Repo unter kargo/ Ordner)
- [x] Container Registry (Docker Hub für Test-Setup)

### Phase 2: Infrastruktur mit OpenTofu & Terragrunt

- [x] Provider Setup (Hetzner, Talos)
- [x] Terragrunt Konfiguration (catalog/ + live/ Pattern)
- [x] Networking Module (VPCs, Firewalls, Floating IPs)
- [x] Talos Cluster Module (Control Plane + Worker)
- [ ] Load Balancer Konfiguration (optional)
- [ ] DNS Records für API Server & Ingress

### Phase 3: Kubernetes Setup

- [ ] Talos Konfiguration generieren
- [ ] Nodes erstellen und booten
- [ ] Cluster bootstrappen
- [ ] CCM & CSI installieren
- [ ] Storage Classes erstellen
- [ ] Ingress Controller (Traefik v3) deployen

### Phase 4: Kargo Integration

- [ ] Cert-Manager installieren
- [ ] ArgoCD installieren
- [ ] Kargo installieren
- [ ] Git Repository einrichten
- [ ] Beispiel-Anwendungen definieren
- [ ] Promotion Pipeline erstellen

### Phase 5: Testing & Documentation

- [ ] End-to-End Tests
- [ ] Performance Tests
- [ ] Security Audit
- [ ] Dokumentation vervollständigen

## Kosten-Optimierungs-Strategien

### Minimal Setup (Aktuelle Planung)

- **Stage**: Single Node Cluster (CPX11, €4/Monat)
- **Prod**: Minimal HA (3x CPX21 + 1x CPX31, ~€35/Monat)
- **Shared Services**: Kargo in Stage Cluster
- **No Load Balancer**: Floating IPs für Stage
- **Local Storage**: Keine zusätzlichen Volumes

### Weitere Optimierungen

- **Preemptible/Spot**: Nicht verfügbar bei Hetzner
- **Autoscaling**: Später hinzufügen bei Bedarf
- **Backups**: Manuelle Snapshots statt automatisiert
- **Monitoring**: Einfaches Monitoring ohne zusätzliche Kosten

**Monatliche Kosten breakdown:**

- Stage: 2x CPX11 = €8
- Prod: 2x CPX21 = €16
- **Total: ~€24/Monat** (+ Traffic)

## Risiken & Mitigation

### Technische Risiken

1. **Talos Learning Curve**: Neue Technologie
   - Mitigation: Test-Umgebung, Dokumentation
2. **Hetzner Limitations**: Weniger Features als AWS/GCP
   - Mitigation: Workarounds dokumentieren
3. **Kargo Integration**: Neuere Technologie
   - Mitigation: Community Support, Examples nutzen

### Betriebsrisiken

1. **Single Region**: Hetzner nur in wenigen Regionen
   - Mitigation: Backup-Strategie, Disaster Recovery Plan
2. **Cost Overrun**: Unkontrollierte Kosten
   - Mitigation: Budget Alerts, Monitoring

## Success-Kriterien

1. **Funktionalität**: Kargo kann erfolgreich zwischen Stage und Prod promoten
2. **Stabilität**: Cluster laufen stabil über 7 Tage
3. **Performance**: Deployment-Pipeline < 5 Minuten
4. **Kosten**: Monatliche Kosten < €50
5. **Documentation**: Setup kann in 2 Stunden reproduziert werden

## Nächste Schritte

1. **Repository initialisieren**
2. **OpenTofu Provider Setup**
3. **Networking Module erstellen**
4. **Talos Cluster Module entwickeln**
5. **Kargo Integration vorbereiten**

---

**Status**: Phase 2 Abgeschlossen - Ready für Deploy  
**Last Updated**: 2026-03-22  
**Owner**: Nils Quirmbach
