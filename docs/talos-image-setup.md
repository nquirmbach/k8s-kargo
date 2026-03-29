# TalOS Image Setup für Hetzner Cloud

## Übersicht

TalOS Images müssen vor dem Deployment zu Hetzner Cloud hochgeladen werden, da Hetzner keine offiziellen TalOS Images bereitstellt.

## Setup mit GitHub Actions (Empfohlen)

### 1. GitHub Secret konfigurieren

1. Gehe zu deinem Repository auf GitHub
2. Navigiere zu **Settings** → **Secrets and variables** → **Actions**
3. Klicke auf **New repository secret**
4. Name: `HCLOUD_TOKEN`
5. Value: Dein Hetzner Cloud API Token
6. Klicke auf **Add secret**

### 2. Workflow ausführen

1. Gehe zu **Actions** → **Build and Upload TalOS Image**
2. Klicke auf **Run workflow**
3. Wähle die gewünschte TalOS Version (Standard: `v1.12.6`)
4. Klicke auf **Run workflow**

### 3. Warten auf Completion

Der Workflow:
- Lädt das TalOS Image herunter (~190 MB)
- Installiert `hcloud-upload-image`
- Lädt das Image zu Hetzner Cloud hoch
- Dauer: ~5-10 Minuten

### 4. Verifizierung

Nach erfolgreichem Upload ist das Image verfügbar als:
- **Name:** `talos-v1.12.6-amd64`
- **Labels:** `os=talos`, `version=v1.12.6`, `arch=amd64`

## Verwendung in Terraform

Das Terraform Module ist bereits konfiguriert:

```hcl
resource "hcloud_server" "controlplane" {
  image = "talos-v1.12.6-amd64"
  # ...
}
```

## Troubleshooting

### Image nicht gefunden

**Fehler:**
```
Error: image talos-v1.12.6-amd64 for architecture x86 not found
```

**Lösung:**
1. Prüfe ob der GitHub Actions Workflow erfolgreich war
2. Verifiziere das Image in der Hetzner Cloud Console unter **Images**
3. Stelle sicher, dass der Image-Name in Terraform korrekt ist

### Workflow schlägt fehl

**Mögliche Ursachen:**
- `HCLOUD_TOKEN` Secret nicht gesetzt oder ungültig
- TalOS Version existiert nicht
- Netzwerkprobleme beim Download

**Lösung:**
1. Prüfe die Workflow-Logs in GitHub Actions
2. Verifiziere das `HCLOUD_TOKEN` Secret
3. Prüfe die TalOS Version auf [factory.talos.dev](https://factory.talos.dev)

## Manuelle Alternative (Nicht empfohlen)

Falls GitHub Actions nicht verfügbar ist:

```bash
# Installiere hcloud-upload-image
go install github.com/apricote/hcloud-upload-image@latest

# Führe das Upload-Script aus
./scripts/upload-talos-image.sh v1.12.6
```

**Voraussetzungen:**
- Go installiert
- `HCLOUD_TOKEN` Umgebungsvariable gesetzt
