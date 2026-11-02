<#
    Import-DonneesDemo.ps1

    Importe les donnees de demo de data/demo/ dans l'environnement connecte. Prerequis : la
    solution SuiviAIPRP importee (tables gk_demande et gk_activite).

    Par defaut, simule : lit les fichiers et compte ce qui serait cree, sans rien ecrire.
    Idempotent : une demande ou une activite dont le numero existe deja n'est pas recreee.

    Le compte connecte devient l'agent assigne de toutes les demandes et l'auteur des
    activites, comme avec New-DemoData.ps1.

    Les flux de la solution reagissent aux creations (le flux 1 ajoute une entree au journal).
    Les desactiver avant l'importation pour obtenir un journal identique a l'export.

    Utilisation :
      .\scripts\Import-DonneesDemo.ps1             # simulation
      .\scripts\Import-DonneesDemo.ps1 -Importer
#>
param(
    [switch]$Importer
)

$ErrorActionPreference = "Stop"

$dv = & "$PSScriptRoot\Connect-Dataverse.ps1"
$Api = "$($dv.OrgUrl)/api/data/v9.2"
$Headers = $dv.Headers

$dossier = Join-Path $PSScriptRoot "..\data\demo"
$demandes = [IO.File]::ReadAllText((Join-Path $dossier "demandes.json"), [Text.Encoding]::UTF8) | ConvertFrom-Json
$activites = [IO.File]::ReadAllText((Join-Path $dossier "activites.json"), [Text.Encoding]::UTF8) | ConvertFrom-Json

$moi = (Invoke-RestMethod -Uri "$Api/WhoAmI" -Headers $Headers).UserId

function Envoyer($Table, $Corps) {
    $h = $Headers.Clone()
    $h["Prefer"] = "return=representation"
    $json = $Corps | ConvertTo-Json -Depth 3
    Invoke-RestMethod -Uri "$Api/$Table" -Method Post -Headers $h -Body ([Text.Encoding]::UTF8.GetBytes($json)) -ContentType "application/json"
}

$ids = @{}
$aCreer = 0
foreach ($d in $demandes) {
    $existant = (Invoke-RestMethod -Uri "$Api/gk_demandes?`$filter=gk_name eq '$($d.numero)'&`$select=gk_demandeid" -Headers $Headers).value
    if ($existant) { $ids[$d.numero] = $existant[0].gk_demandeid; continue }
    $aCreer++
    if (-not $Importer) { continue }
    $corps = [ordered]@{
        gk_name                          = $d.numero
        gk_nomdemandeur                  = $d.nomDemandeur
        gk_courrieldemandeur             = $d.courrielDemandeur
        gk_objet                         = $d.objet
        gk_type                          = $d.type
        gk_classification                = $d.classification
        gk_datereception                 = $d.dateReception
        gk_dateecheance                  = $d.dateEcheance
        gk_statut                        = $d.statut
        "gk_AgentAssigneId@odata.bind"   = "/systemusers($moi)"
    }
    if ($d.motifProrogation) { $corps.gk_motifprorogation = $d.motifProrogation }
    if ($d.nouvelleEcheanceProrog) { $corps.gk_nouvelleecheanceprorogation = $d.nouvelleEcheanceProrog }
    $ids[$d.numero] = (Envoyer "gk_demandes" $corps).gk_demandeid
}
Write-Host "Demandes : $aCreer a creer sur $(@($demandes).Count)." -ForegroundColor Cyan

$aCreerA = 0
foreach ($a in $activites) {
    $existant = (Invoke-RestMethod -Uri "$Api/gk_activites?`$filter=gk_name eq '$($a.numero)'&`$select=gk_activiteid" -Headers $Headers).value
    if ($existant) { continue }
    $aCreerA++
    if (-not $Importer) { continue }
    Envoyer "gk_activites" ([ordered]@{
        gk_name                      = $a.numero
        gk_date                      = $a.date
        gk_action                    = $a.action
        gk_commentaire               = $a.commentaire
        "gk_DemandeId@odata.bind"    = "/gk_demandes($($ids[$a.demande]))"
        "gk_AuteurId@odata.bind"     = "/systemusers($moi)"
    }) | Out-Null
}
Write-Host "Activites : $aCreerA a creer sur $(@($activites).Count)." -ForegroundColor Cyan

if (-not $Importer) { Write-Host "[simulation] Rien n'a ete cree. Relancer avec -Importer." -ForegroundColor Yellow }
