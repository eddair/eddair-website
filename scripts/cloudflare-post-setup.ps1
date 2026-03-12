# Cloudflare Pages - Env Vars + Domains (nach manueller Projekterstellung)
# Fuehre NACH Schritt 3 (Projekt im Browser angelegt) aus.
#
# Verwendung:
#   $env:CLOUDFLARE_API_TOKEN = "dein-token"
#   $env:SUPABASE_ANON_KEY = "dein-anon-key"   # aus Supabase Dashboard -> Settings -> API
#   .\scripts\cloudflare-post-setup.ps1

param(
    [string]$SupabaseAnonKey = $env:SUPABASE_ANON_KEY
)

$ACCOUNT_ID = "396f4499b152cc538ee06c68ba5a6904"
$PROJECT_NAME = "eddair-website"
$PUBLIC_SUPABASE_URL = "https://ijawvbdjkltqjtcgpfgc.supabase.co"

if (-not $env:CLOUDFLARE_API_TOKEN) {
    Write-Host "FEHLER: CLOUDFLARE_API_TOKEN ist nicht gesetzt." -ForegroundColor Red
    Write-Host "  `$env:CLOUDFLARE_API_TOKEN = 'dein-token'" -ForegroundColor Yellow
    exit 1
}

if (-not $SupabaseAnonKey) {
    Write-Host "FEHLER: SUPABASE_ANON_KEY fehlt." -ForegroundColor Red
    Write-Host "  Hole ihn aus: https://supabase.com/dashboard/project/ijawvbdjkltqjtcgpfgc/settings/api" -ForegroundColor Yellow
    Write-Host "  Dann: `$env:SUPABASE_ANON_KEY = 'dein-anon-key'" -ForegroundColor Yellow
    exit 1
}

$headers = @{
    "Authorization" = "Bearer $env:CLOUDFLARE_API_TOKEN"
    "Content-Type" = "application/json"
}

# === Schritt 4: Environment Variables setzen ===
Write-Host "`n=== Schritt 4: Environment Variables setzen ===" -ForegroundColor Cyan

$deploymentConfigs = @{
    deployment_configs = @{
        production = @{
            env_vars = @{
                NODE_VERSION = @{ type = "plain_text"; value = "22" }
                PUBLIC_SUPABASE_URL = @{ type = "plain_text"; value = $PUBLIC_SUPABASE_URL }
                PUBLIC_SUPABASE_ANON_KEY = @{ type = "plain_text"; value = $SupabaseAnonKey }
            }
        }
        preview = @{
            env_vars = @{
                NODE_VERSION = @{ type = "plain_text"; value = "22" }
                PUBLIC_SUPABASE_URL = @{ type = "plain_text"; value = $PUBLIC_SUPABASE_URL }
                PUBLIC_SUPABASE_ANON_KEY = @{ type = "plain_text"; value = $SupabaseAnonKey }
            }
        }
    }
} | ConvertTo-Json -Depth 10

try {
    $response = Invoke-RestMethod `
        -Uri "https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/pages/projects/$PROJECT_NAME" `
        -Method PATCH `
        -Headers $headers `
        -Body $deploymentConfigs
    if ($response.success) {
        Write-Host "Env Vars gesetzt: NODE_VERSION, PUBLIC_SUPABASE_URL, PUBLIC_SUPABASE_ANON_KEY" -ForegroundColor Green
    } else {
        Write-Host "Fehler: $($response.errors | ConvertTo-Json)" -ForegroundColor Red
    }
} catch {
    Write-Host "Fehler beim Setzen der Env Vars: $_" -ForegroundColor Red
    Write-Host "Pruefe ob das Projekt '$PROJECT_NAME' existiert (Schritt 3 im Browser)." -ForegroundColor Yellow
}

# === Schritt 5: Custom Domains hinzufuegen ===
Write-Host "`n=== Schritt 5: Custom Domains hinzufuegen ===" -ForegroundColor Cyan

foreach ($domain in @("eddair.com", "www.eddair.com")) {
    try {
        $body = @{ name = $domain } | ConvertTo-Json
        $response = Invoke-RestMethod `
            -Uri "https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/pages/projects/$PROJECT_NAME/domains" `
            -Method POST `
            -Headers $headers `
            -Body $body
        if ($response.success) {
            Write-Host "  $domain hinzugefuegt." -ForegroundColor Green
        } else {
            Write-Host "  $domain : $($response.errors.message -join ', ')" -ForegroundColor Yellow
        }
    } catch {
        $errMsg = $_.ErrorDetails.Message
        if ($errMsg -match "already exists") {
            Write-Host "  $domain existiert bereits." -ForegroundColor Yellow
        } else {
            Write-Host "  $domain Fehler: $_" -ForegroundColor Red
        }
    }
}

Write-Host "`nFertig! Pruefe den Build in Cloudflare Pages." -ForegroundColor Green
