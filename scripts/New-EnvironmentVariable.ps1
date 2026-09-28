<#
    New-EnvironmentVariable.ps1

    Cree la variable d'environnement gk_EnvoiCourrielActif (Booleen), utilisee par le flux
    "Demande recue" pour activer/desactiver l'envoi du courriel d'accusé de reception sans
    modifier le flux lui-meme. Valeur par defaut : false (cet environnement de developpement
    n'a pas de licence Exchange/Outlook). A remettre a true dans un environnement avec une
    vraie boite aux lettres.

    Idempotent : peut etre relance sans dupliquer.

    Utilisation :
      .\scripts\New-EnvironmentVariable.ps1
#>

$ErrorActionPreference = "Stop"

$dv = & "$PSScriptRoot\Connect-Dataverse.ps1"
$OrgUrl = $dv.OrgUrl
$Headers = $dv.Headers
$SolutionName = "SuiviAIPRP"

$schemaName = "gk_EnvoiCourrielActif"

$existant = Invoke-RestMethod -Uri "$OrgUrl/api/data/v9.2/environmentvariabledefinitions?`$filter=schemaname eq '$schemaName'&`$select=environmentvariabledefinitionid" -Headers $Headers -Method Get

if ($existant.value.Count -gt 0) {
    Write-Host "Variable d'environnement $schemaName existe deja." -ForegroundColor DarkGray
} else {
    $body = @{
        schemaname   = $schemaName
        displayname  = "Envoi de courriel actif"
        description  = "Active ou desactive l'envoi du courriel d'accuse de reception dans le flux Demande recue. False dans cet environnement de developpement (pas de licence Exchange/Outlook) ; a mettre a true dans un environnement avec une vraie boite aux lettres."
        type         = 100000002
        defaultvalue = "false"
    } | ConvertTo-Json

    $h = $Headers.Clone()
    $h["MSCRM.SolutionUniqueName"] = $SolutionName
    Invoke-RestMethod -Uri "$OrgUrl/api/data/v9.2/environmentvariabledefinitions" -Method Post -Headers $h -Body $body | Out-Null
    Write-Host "Variable d'environnement $schemaName creee (type Booleen, defaut false)." -ForegroundColor Green
}
