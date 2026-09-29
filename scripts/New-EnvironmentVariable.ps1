<#
    New-EnvironmentVariable.ps1

    Cree la variable d'environnement gk_EnvoiCourrielActif (Booleen), utilisee par le flux
    "Demande recue" pour activer/desactiver l'envoi du courriel d'accuse de reception sans
    modifier le flux lui-meme. Valeur par defaut : "no" (cet environnement de developpement
    n'a pas de licence Exchange/Outlook). A remettre a "yes" dans un environnement avec une
    vraie boite aux lettres.

    IMPORTANT : les variables d'environnement Booleen de Dataverse stockent "yes"/"no",
    pas "true"/"false". L'API accepte "false"/"true" sans erreur a la creation, mais le
    portail Power Automate/Power Apps n'interprete pas cette valeur correctement (constate
    en test : la variable s'affichait a "Non" par defaut independamment de ce qui avait ete
    ecrit). Voir docs/flux.md pour le piege complet.

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
        description  = "Active ou desactive l'envoi du courriel d'accuse de reception dans le flux Demande recue. 'no' dans cet environnement de developpement (pas de licence Exchange/Outlook) ; a mettre a 'yes' dans un environnement avec une vraie boite aux lettres."
        type         = 100000002
        defaultvalue = "no"
    } | ConvertTo-Json

    $h = $Headers.Clone()
    $h["MSCRM.SolutionUniqueName"] = $SolutionName
    Invoke-RestMethod -Uri "$OrgUrl/api/data/v9.2/environmentvariabledefinitions" -Method Post -Headers $h -Body $body | Out-Null
    Write-Host "Variable d'environnement $schemaName creee (type Booleen, defaut no)." -ForegroundColor Green
}
