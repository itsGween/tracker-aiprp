<#
    Export-DonneesDemo.ps1

    Exporte les 15 demandes de demo (A-2026-01001 a A-2026-01015) et leur journal dans
    data/demo/, au format JSON, pour les reimporter avec Import-DonneesDemo.ps1.

    Ne sont pas exportes : les identifiants (GUID), l'agent assigne, l'auteur des activites et
    gk_daterappel, propres a chaque environnement. Les courriels des demandeurs sont reecrits
    sur le domaine reserve example.com. Les demandes de test (A-2026-01016 et suivantes) sont
    exclues.

    -Dossier permet d'exporter ailleurs que dans data/demo/, par exemple pour comparer un
    environnement redeploye avec le depot sans ecraser les fichiers versionnes.

    Utilisation :
      .\scripts\Export-DonneesDemo.ps1
      .\scripts\Export-DonneesDemo.ps1 -EnvFile scripts\.env.essai -Dossier out\essai
#>
param(
    [string]$EnvFile = (Join-Path $PSScriptRoot ".env"),
    [string]$Dossier = (Join-Path $PSScriptRoot "..\data\demo")
)

$ErrorActionPreference = "Stop"

$dv = & "$PSScriptRoot\Connect-Dataverse.ps1" -EnvFile $EnvFile
$Api = "$($dv.OrgUrl)/api/data/v9.2"
$Headers = $dv.Headers

$dossier = $Dossier
New-Item -ItemType Directory -Force $dossier | Out-Null

$champs = "gk_demandeid,gk_name,gk_nomdemandeur,gk_courrieldemandeur,gk_objet,gk_type,gk_classification,gk_datereception,gk_dateecheance,gk_statut,gk_motifprorogation,gk_nouvelleecheanceprorogation"
$lignes = (Invoke-RestMethod -Uri "$Api/gk_demandes?`$select=$champs&`$filter=gk_name ge 'A-2026-01001' and gk_name le 'A-2026-01015'&`$orderby=gk_name" -Headers $Headers).value
if (@($lignes).Count -ne 15) { throw "Attendu 15 demandes de demo, trouve $(@($lignes).Count)." }

$demandes = foreach ($d in $lignes) {
    [ordered]@{
        numero                  = $d.gk_name
        nomDemandeur            = $d.gk_nomdemandeur
        courrielDemandeur       = ($d.gk_courrieldemandeur -replace '@.*$', '@example.com')
        objet                   = $d.gk_objet
        type                    = $d.gk_type
        classification          = $d.gk_classification
        dateReception           = $d.gk_datereception
        dateEcheance            = $d.gk_dateecheance
        statut                  = $d.gk_statut
        motifProrogation        = $d.gk_motifprorogation
        nouvelleEcheanceProrog  = $d.gk_nouvelleecheanceprorogation
    }
}

$parId = @{}
foreach ($d in $lignes) { $parId[$d.gk_demandeid] = $d.gk_name }
$filtre = ($lignes | ForEach-Object { "_gk_demandeid_value eq $($_.gk_demandeid)" }) -join " or "
$acts = (Invoke-RestMethod -Uri "$Api/gk_activites?`$select=gk_name,gk_date,gk_action,gk_commentaire,_gk_demandeid_value&`$filter=$filtre&`$orderby=gk_name" -Headers $Headers).value

$activites = foreach ($a in $acts) {
    [ordered]@{
        numero      = $a.gk_name
        demande     = $parId[$a._gk_demandeid_value]
        date        = $a.gk_date
        action      = $a.gk_action
        commentaire = $a.gk_commentaire
    }
}

$utf8 = New-Object Text.UTF8Encoding($false)
[IO.File]::WriteAllText((Join-Path $dossier "demandes.json"), (ConvertTo-Json @($demandes) -Depth 3), $utf8)
[IO.File]::WriteAllText((Join-Path $dossier "activites.json"), (ConvertTo-Json @($activites) -Depth 3), $utf8)
Write-Host "Exporte : $(@($demandes).Count) demandes, $(@($activites).Count) activites dans $dossier." -ForegroundColor Green
