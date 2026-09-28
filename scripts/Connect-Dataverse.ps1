<#
    Connect-Dataverse.ps1

    Obtient un jeton d'acces OAuth scope pour l'API Web Dataverse et le met en cache
    localement (hors du depot) pour eviter de se reconnecter a chaque script.

    Prerequis :
      - Module MSAL.PS installe (Install-Module MSAL.PS -Scope CurrentUser)
      - scripts/.env rempli a partir de scripts/.env.example (jamais commite)

    Utilisation :
      $dv = & "$PSScriptRoot\Connect-Dataverse.ps1"
      Invoke-RestMethod -Uri "$($dv.OrgUrl)/api/data/v9.2/..." -Headers $dv.Headers

    Le jeton est mis en cache dans un fichier temporaire (%TEMP%), jamais dans le depot,
    et reutilise tant qu'il n'est pas expire. Utiliser -Force pour forcer une reconnexion.
#>
param(
    [switch]$Force
)

$ErrorActionPreference = "Stop"

# Charge scripts/.env (jamais commite - voir .env.example pour le gabarit)
$envFile = Join-Path $PSScriptRoot ".env"
if (-not (Test-Path $envFile)) {
    throw "Fichier scripts/.env introuvable. Copie scripts/.env.example en scripts/.env et remplis-le."
}
Get-Content $envFile | Where-Object { $_ -match "=" -and $_ -notmatch "^\s*#" } | ForEach-Object {
    $name, $value = $_ -split "=", 2
    Set-Item -Path "Env:$($name.Trim())" -Value $value.Trim()
}

$orgUrl = $env:AIPRP_DATAVERSE_URL
$tenantId = $env:AIPRP_TENANT_ID
if (-not $orgUrl -or -not $tenantId) {
    throw "AIPRP_DATAVERSE_URL et AIPRP_TENANT_ID doivent etre definis dans scripts/.env"
}

# Jeton mis en cache hors du depot (expire naturellement ; jamais versionne)
$cacheFile = Join-Path $env:TEMP "aiprp-dataverse-token.json"

if (-not $Force -and (Test-Path $cacheFile)) {
    $cached = Get-Content $cacheFile -Raw | ConvertFrom-Json
    if ([datetime]$cached.expiresOn -gt (Get-Date).AddMinutes(2)) {
        return [pscustomobject]@{
            OrgUrl  = $cached.orgUrl
            Headers = @{
                "Authorization"    = "Bearer $($cached.accessToken)"
                "OData-MaxVersion" = "4.0"
                "OData-Version"    = "4.0"
                "Accept"           = "application/json"
                "Content-Type"     = "application/json; charset=utf-8"
            }
        }
    }
}

Import-Module MSAL.PS -ErrorAction Stop

# ID client public bien connu des outils Dataverse (utilise aussi par pac CLI) -
# pre-consenti dans la plupart des tenants, pas d'inscription d'application requise.
$clientId = "51f81489-12ee-4a9e-aaae-a2591f45987d"

Write-Host "Connexion a Dataverse requise - suis les instructions ci-dessous pour te connecter dans un navigateur." -ForegroundColor Cyan
$token = Get-MsalToken -ClientId $clientId -TenantId $tenantId -Scopes "$orgUrl/.default" -DeviceCode

@{
    accessToken = $token.AccessToken
    expiresOn   = $token.ExpiresOn.ToString("o")
    orgUrl      = $orgUrl
} | ConvertTo-Json | Set-Content $cacheFile

Write-Host "Connecte comme $($token.Account.Username). Jeton valide jusqu'a $($token.ExpiresOn)." -ForegroundColor Green

[pscustomobject]@{
    OrgUrl  = $orgUrl
    Headers = @{
        "Authorization"    = "Bearer $($token.AccessToken)"
        "OData-MaxVersion" = "4.0"
        "OData-Version"    = "4.0"
        "Accept"           = "application/json"
        "Content-Type"     = "application/json; charset=utf-8"
    }
}
