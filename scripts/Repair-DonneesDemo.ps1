<#
    Repair-DonneesDemo.ps1

    Correction ponctuelle des donnees de demo. Par defaut, simule et affiche ce qui
    serait modifie ; rien n'est ecrit sans -Appliquer.

    1. A-2026-01003 : remet le statut a En traitement et journalise la correction. La
       demande avait ete passee a Prorogation demandee par la liste de statuts, sans
       motif ni nouvelle echeance.
    2. Activites du script de demo : les deplace de minuit UTC (la veille a Ottawa) a
       midi, heure d'Ottawa, le meme jour. Seul gk_date change.

    Idempotent : une fois corrigees, les lignes ne correspondent plus aux criteres.

    Utilisation :
      .\scripts\Repair-DonneesDemo.ps1             # simulation
      .\scripts\Repair-DonneesDemo.ps1 -Appliquer
#>
param(
    [switch]$Appliquer
)

$ErrorActionPreference = "Stop"

$dv = & "$PSScriptRoot\Connect-Dataverse.ps1"
$OrgUrl = $dv.OrgUrl
$Headers = $dv.Headers

$StatutEnTraitement = 100000011
$StatutProrogationDemandee = 100000015
$ActionChangementStatut = 100000031
$Api = "$OrgUrl/api/data/v9.2"
$Ottawa = [TimeZoneInfo]::FindSystemTimeZoneById("Eastern Standard Time")

# Corps en octets : Windows PowerShell 5.1 n'encode pas une chaine en UTF-8.
# La virgule empeche PowerShell de derouler le tableau d'octets en sortie de fonction.
function ConvertTo-CorpsUtf8 {
    param([hashtable]$Valeurs)
    , [byte[]][Text.Encoding]::UTF8.GetBytes(($Valeurs | ConvertTo-Json))
}

# --- 1. A-2026-01003 ---
$demande = (Invoke-RestMethod -Uri "$Api/gk_demandes?`$select=gk_demandeid,gk_statut&`$filter=gk_name eq 'A-2026-01003'" -Headers $Headers).value[0]

if ($demande.gk_statut -ne $StatutProrogationDemandee) {
    Write-Host "A-2026-01003 : statut deja corrige, rien a faire." -ForegroundColor DarkGray
} elseif (-not $Appliquer) {
    Write-Host "[simulation] A-2026-01003 : Prorogation demandee -> En traitement, + 1 activite." -ForegroundColor Yellow
} else {
    $auteurId = (Invoke-RestMethod -Uri "$Api/WhoAmI" -Headers $Headers).UserId
    $e = [char]0xE9
    $commentaire = "Correction de donn${e}es : statut remis $([char]0xE0) En traitement. La prorogation avait $([char]0xE9)t$e pos${e}e par la liste de statuts, sans motif ni nouvelle $([char]0xE9)ch$([char]0xE9)ance."

    Invoke-RestMethod -Uri "$Api/gk_demandes($($demande.gk_demandeid))" -Method Patch -Headers $Headers `
        -Body (ConvertTo-CorpsUtf8 @{ gk_statut = $StatutEnTraitement }) | Out-Null
    Invoke-RestMethod -Uri "$Api/gk_activites" -Method Post -Headers $Headers -Body (ConvertTo-CorpsUtf8 @{
        gk_date                   = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
        gk_action                 = $ActionChangementStatut
        gk_commentaire            = $commentaire
        "gk_DemandeId@odata.bind" = "/gk_demandes($($demande.gk_demandeid))"
        "gk_AuteurId@odata.bind"  = "/systemusers($auteurId)"
    }) | Out-Null
    Write-Host "A-2026-01003 : statut corrige et activite ajoutee." -ForegroundColor Green
}

# --- 2. Activites du script de demo ---
# On lit la valeur brute : le type [datetime] de ConvertFrom-Json depend du contexte.
$reponse = Invoke-WebRequest -Uri "$Api/gk_activites?`$select=gk_name,gk_date,_gk_demandeid_value&`$orderby=gk_name" -Headers $Headers -UseBasicParsing
$activites = [regex]::Matches($reponse.Content, '\{[^{}]*\}') | ForEach-Object {
    $ligne = $_.Value
    [pscustomobject]@{
        Id      = [regex]::Match($ligne, '"gk_activiteid":"([^"]+)"').Groups[1].Value
        Nom     = [regex]::Match($ligne, '"gk_name":"([^"]+)"').Groups[1].Value
        Date    = [regex]::Match($ligne, '"gk_date":"([^"]+)"').Groups[1].Value
        Demande = [regex]::Match($ligne, '"_gk_demandeid_value":"([^"]+)"').Groups[1].Value
    }
} | Where-Object { $_.Id }

$aCorriger = @($activites | Where-Object { $_.Demande -and $_.Date -match '^(\d{4}-\d{2}-\d{2})T00:00:00Z$' })
Write-Host "Activites lues : $($activites.Count). A deplacer a midi : $($aCorriger.Count)." -ForegroundColor Cyan

foreach ($a in $aCorriger) {
    $jour = [datetime]::ParseExact($a.Date.Substring(0, 10), "yyyy-MM-dd", $null)
    $midi = [TimeZoneInfo]::ConvertTimeToUtc($jour.AddHours(12), $Ottawa).ToString("yyyy-MM-ddTHH:mm:ssZ")
    if ($Appliquer) {
        Invoke-RestMethod -Uri "$Api/gk_activites($($a.Id))" -Method Patch -Headers $Headers `
            -Body (ConvertTo-CorpsUtf8 @{ gk_date = $midi }) | Out-Null
    }
    Write-Host "  $($a.Nom) : $($a.Date) -> $midi"
}

if (-not $Appliquer) {
    Write-Host "Simulation terminee, rien n'a ete modifie. Relance avec -Appliquer." -ForegroundColor Yellow
}
