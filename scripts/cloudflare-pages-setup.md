# Cloudflare Pages Setup – eddair-website

## Voraussetzung

**CLOUDFLARE_API_TOKEN** setzen (mit Berechtigung "Pages Write"):

- Token erstellen: https://dash.cloudflare.com/profile/api-tokens
- Oder: `$env:CLOUDFLARE_API_TOKEN = "dein-token"` (PowerShell)

---

## Schritt 1: Altes Projekt löschen

**Option A – Skript ausführen:**
```powershell
cd C:\Users\Hayati\Documents\Claude\eddair-site
$env:CLOUDFLARE_API_TOKEN = "dein-token"  # falls noch nicht gesetzt
.\scripts\cloudflare-setup.ps1
```

**Option B – Einzelbefehle:**
```powershell
cd C:\Users\Hayati\Documents\Claude\eddair-site
npx wrangler pages project delete eddair-website
```

Falls das Projekt nicht existiert: Fehlermeldung ignorieren.

---

## Schritt 2: Manuell im Browser

### 2a) GitHub App deinstallieren

1. https://github.com/settings/installations
2. "Cloudflare Workers and Pages" → **Configure** → **Uninstall**

### 2b) In Cloudflare neu verbinden

1. https://dash.cloudflare.com → **Workers & Pages**
2. **Create application** → **Pages** → **Connect to Git**
3. **GitHub** → **+ Add account**
4. Account **eddair** → **All repositories** → **Install & Authorize**
5. Prüfen: Repositories müssen erscheinen

### 2c) Neues Projekt anlegen (im Dashboard)

- **Repository:** eddair/eddair-website
- **Branch:** main
- **Framework preset:** Astro
- **Build command:** `npm run build`
- **Build output directory:** `dist`
- **Root directory:** *(leer)*

**Environment Variables** (Production) im Dashboard eintragen:

| Key | Value |
|-----|-------|
| NODE_VERSION | 22 |
| PUBLIC_SUPABASE_URL | https://ijawvbdjkltqjtcgpfgc.supabase.co |
| PUBLIC_SUPABASE_ANON_KEY | *(aus Supabase → Settings → API)* |

---

## Schritt 3: Custom Domains per API hinzufügen

**Nach** dem manuellen Anlegen des Projekts:

```powershell
$ACCOUNT_ID = "396f4499b152cc538ee06c68ba5a6904"
$PROJECT_NAME = "eddair-website"
$TOKEN = $env:CLOUDFLARE_API_TOKEN

# Domain eddair.com hinzufügen
Invoke-RestMethod -Uri "https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/pages/projects/$PROJECT_NAME/domains" `
  -Method POST `
  -Headers @{
    "Authorization" = "Bearer $TOKEN"
    "Content-Type" = "application/json"
  } `
  -Body '{"name":"eddair.com"}'

# Domain www.eddair.com hinzufügen
Invoke-RestMethod -Uri "https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/pages/projects/$PROJECT_NAME/domains" `
  -Method POST `
  -Headers @{
    "Authorization" = "Bearer $TOKEN"
    "Content-Type" = "application/json"
  } `
  -Body '{"name":"www.eddair.com"}'
```

**Alternative:** Domains im Dashboard unter **Settings → Domains** hinzufügen.

---

## Schritt 4: Prüfen

- Build in Cloudflare Pages: grün
- https://eddair.com zeigt die neue Seite
- DNS für eddair.com zeigt auf Cloudflare (CNAME oder A-Record)

---

## GitHub-IDs (für Referenz)

- **Repo ID:** 1179329669
- **Owner ID:** 247251208
