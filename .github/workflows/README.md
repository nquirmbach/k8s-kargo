# GitHub Actions Workflows

## Build TalOS Image

Der Workflow `build-talos-image.yml` baut und lädt TalOS Images zu Hetzner Cloud hoch.

### Setup

1. **GitHub Secret erstellen:**
   - Gehe zu Repository Settings → Secrets and variables → Actions
   - Erstelle ein neues Secret: `HCLOUD_TOKEN`
   - Wert: Dein Hetzner Cloud API Token

### Verwendung

**Manuell triggern:**
1. Gehe zu Actions → Build and Upload TalOS Image
2. Klicke auf "Run workflow"
3. Wähle die TalOS Version (z.B. `v1.12.6`)
4. Klicke auf "Run workflow"

**Automatisch:**
- Der Workflow läuft automatisch bei Änderungen an der Workflow-Datei

### Output

Nach erfolgreichem Lauf:
- Image Name: `talos-{VERSION}-amd64`
- Labels: `os=talos`, `version={VERSION}`, `arch=amd64`
- Verwendbar in Terraform mit: `image = "talos-v1.12.6-amd64"`
