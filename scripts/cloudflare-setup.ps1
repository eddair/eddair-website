# Cloudflare Pages Setup Script
# Voraussetzung: $env:CLOUDFLARE_API_TOKEN muss gesetzt sein

$ACCOUNT_ID = "396f4499b152cc538ee06c68ba5a6904"
$PROJECT_NAME = "eddair-website"

if (-not $env:CLOUDFLARE_API_TOKEN) {
    Write-Host "FEHLER: CLOUDFLARE_API_TOKEN ist nicht gesetzt." -ForegroundColor Red
    Write-Host "Setze ihn mit: `$env:CLOUDFLARE_API_TOKEN = 'dein-token'" -ForegroundColor Yellow
    exit 1
}

Write-Host "=== Schritt 1: Altes Projekt loeschen ===" -ForegroundColor Cyan
npx wrangler pages project delete $PROJECT_NAME 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Projekt existiert nicht oder konnte nicht geloescht werden (ignorierbar)" -ForegroundColor Yellow
}

Write-Host "`n=== Naechste Schritte (manuell im Browser) ===" -ForegroundColor Cyan
Write-Host "1. GitHub App deinstallieren: https://github.com/settings/installations"
Write-Host "2. Cloudflare: Workers & Pages -> Create -> Pages -> Connect to Git"
Write-Host "3. Projekt anlegen: eddair/eddair-website, main, Astro, npm run build, dist"
Write-Host "4. Env Vars: NODE_VERSION=22, PUBLIC_SUPABASE_URL, PUBLIC_SUPABASE_ANON_KEY"
Write-Host "`n=== NACH dem manuellen Anlegen: Domains per API hinzufuegen ===" -ForegroundColor Cyan
Write-Host "Fuehre diesen Befehl aus (oder druecke Enter zum Ausfuehren):" -ForegroundColor Yellow
Write-Host ""

$addDomains = Read-Host "Domains jetzt hinzufuegen? (j/n)"

if ($addDomains -eq "j" -or $addDomains -eq "J" -or $addDomains -eq "y" -or $addDomains -eq "Y") {
    Write-Host "`nFuege eddair.com hinzu..." -ForegroundColor Green
    try {
        Invoke-RestMethod -Uri "https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/pages/projects/$PROJECT_NAME/domains" `
            -Method POST `
            -Headers @{
                "Authorization" = "Bearer $env:CLOUDFLARE_API_TOKEN"
                "Content-Type" = "application/json"
            } `
            -Body '{"name":"eddair.com"}'
        Write-Host "eddair.com hinzugefuegt." -ForegroundColor Green
    } catch {
        Write-Host "Fehler: $_" -ForegroundColor Red
    }

    Write-Host "Fuege www.eddair.com hinzu..." -ForegroundColor Green
    try {
        Invoke-RestMethod -Uri "https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/pages/projects/$PROJECT_NAME/domains" `
            -Method POST `
            -Headers @{
                "Authorization" = "Bearer $env:CLOUDFLARE_API_TOKEN"
                "Content-Type" = "application/json"
            } `
            -Body '{"name":"www.eddair.com"}'
        Write-Host "www.eddair.com hinzugefuegt." -ForegroundColor Green
    } catch {
        Write-Host "Fehler: $_" -ForegroundColor Red
    }
} else {
    Write-Host "`nDomains manuell hinzufuegen: Settings -> Domains -> eddair.com, www.eddair.com" -ForegroundColor Yellow
}

Write-Host "`nFertig!" -ForegroundColor Green
