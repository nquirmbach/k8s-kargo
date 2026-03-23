# AGENTS.md - Information für AI Agents

Diese Datei enthält wichtige Informationen für AI Agents, die an diesem Repository arbeiten.

## Projekt-Übersicht

**Kargo auf Hetzner Cloud mit Talos OS**

Ein Kubernetes Test-Setup für Kargo (Continuous Promotion Orchestration) mit:
- 2 Environments: Stage und Prod
- Jeweils 1 Control Plane + 1 Worker Node
- Talos OS als immutable Kubernetes Platform
- Terragrunt + OpenTofu für Infrastructure as Code

## Architektur

```
catalog/           # OpenTofu Module (reusable)
├── modules/
│   ├── networking/    # VPC, Firewall, Floating IPs
│   └── talos-cluster/ # Talos Kubernetes Cluster

live/              # Terragrunt Konfigurationen
├── root.hcl         # Global Provider Config
├── stage/
│   ├── terragrunt.hcl
│   ├── networking/terragrunt.hcl
│   └── cluster/terragrunt.hcl
└── prod/
    ├── terragrunt.hcl
    ├── networking/terragrunt.hcl
    └── cluster/terragrunt.hcl
```

## Wichtige Konventionen

### 1. Datei-Typen
- **`.tf`** - OpenTofu Module Code (in `catalog/modules/`)
- **`.hcl`** - Terragrunt Konfigurationen (in `live/`)
- **`.tf` generiert** - Von Terragrunt generiert (nicht manuell editieren)

### 2. Dependencies

**Networking** hat keine Dependencies.
**Cluster** hat Dependency auf Networking:
```hcl
dependency "networking" {
  config_path = "../networking"
  
  mock_outputs = {
    network_id      = 12345678
    subnet_id       = 12345678
    firewall_id     = 12345678
    api_floating_ip = "10.0.0.1"
    api_floating_ip_id = 12345678
  }
}
```

### 3. Versions
- OpenTofu: >= 1.8.0
- Terragrunt: ~> 0.99.4 (aktuell installiert)
- Talos Provider: ~> 0.7.0
- Hetzner Provider: ~> 1.45.0

## Nutzung

### Commands

```bash
# Environment planen
task tg:plan ENV=stage

# Environment deployen
task tg:apply ENV=stage

# Environment löschen
task tg:destroy ENV=stage

# Einzelne Unit (für Debugging)
task tg:plan-unit ENV=stage UNIT=networking
```

### Direkte Terragrunt Nutzung

```bash
cd live/stage
terragrunt run -- run-all plan
terragrunt run -- run-all apply
```

## Technische Details

### Networking Module Outputs
- `network_id` - Hetzner Network ID
- `subnet_id` - Subnet ID
- `firewall_id` - Firewall ID
- `api_floating_ip` - IP Adresse für API Server
- `api_floating_ip_id` - Floating IP ID für Assignment
- `ingress_floating_ip` - IP für Ingress

### Talos Cluster Module Inputs
- `environment` - stage/prod
- `cluster_name` - z.B. "kargo-stage"
- `kubernetes_version` - v1.32.13
- `talos_version` - v1.12.6
- `control_plane_node_type` - cpx11/cpx21
- `worker_node_type` - cpx11/cpx21
- `network_id`, `subnet_id`, `firewall_id` - von Networking
- `api_floating_ip_id`, `api_floating_ip` - von Networking

### Kosten
- Stage: 2x CPX11 = ~€8/Monat
- Prod: 2x CPX21 = ~€16/Monat
- Total: ~€24/Monat

## Häufige Fehler

### "Unknown variable dependency"
**Ursache:** `dependency` Block fehlt oder ist falsch
**Lösung:** `dependency` mit `mock_outputs` hinzufügen

### "no Floating IP found"
**Ursache:** `data.hcloud_floating_ip` sucht nach nicht existierender IP
**Lösung:** Floating IP ID statt IP verwenden, oder `mock_outputs` prüfen

### "duplicate variable declaration"
**Ursache:** Variablen in `main.tf` und `variables.tf` definiert
**Lösung:** Variablen nur in `variables.tf` definieren

## Best Practices

1. **Keine `main.tf` in `live/`** - Nur `.hcl` Dateien
2. **Keine `terragrunt.hcl` in `catalog/`** - Nur `.tf` Dateien
3. **Immer `mock_outputs` verwenden** - Für Dependencies
4. **Taskfile nutzen** - Für konsistente Commands
5. **Environment-Variable `HETZNER_API_TOKEN`** - Muss gesetzt sein

## Ressourcen

- [Terragrunt Dokumentation](https://terragrunt.gruntwork.io/docs/)
- [Talos OS Dokumentation](https://www.talos.dev/)
- [Hetzner Cloud Provider](https://registry.opentofu.org/providers/hetznercloud/hcloud/latest)
- [Kargo Dokumentation](https://kargo.akuity.io/)

## Kontakt

**Repository Owner:** Nils Quirmbach  
**Status:** Phase 2 Abgeschlossen - Ready für Deploy
