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

    Cree aussi gk_ApprobateurProrogation (Texte), le compte qui recoit les approbations du
    flux "Approbation de prorogation". La definition, sans valeur par defaut, va dans la
    solution. La valeur courante est propre a l'environnement : elle prend le compte connecte,
    n'entre pas dans la solution et n'apparait donc pas dans le depot a l'export.
    Cree de la meme facon gk_DestinataireRappels, le compte qui recoit les rappels du flux
    "Rappel quotidien des echeances".

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

$comptes = @(
    @{
        Schema      = "gk_ApprobateurProrogation"
        Nom         = "Approbateur des prorogations"
        Description = "Compte (UPN) qui recoit les approbations du flux Approbation de prorogation. Valeur propre a chaque environnement."
    },
    @{
        Schema      = "gk_DestinataireRappels"
        Nom         = "Destinataire des rappels"
        Description = "Compte (UPN) qui recoit les rappels du flux Rappel quotidien des echeances. Valeur propre a chaque environnement."
    }
)

foreach ($compte in $comptes) {
    $schema = $compte.Schema

    $existant = Invoke-RestMethod -Uri "$OrgUrl/api/data/v9.2/environmentvariabledefinitions?`$filter=schemaname eq '$schema'&`$select=environmentvariabledefinitionid" -Headers $Headers -Method Get

    if ($existant.value.Count -gt 0) {
        $definitionId = $existant.value[0].environmentvariabledefinitionid
        Write-Host "Variable d'environnement $schema existe deja." -ForegroundColor DarkGray
    } else {
        $body = @{
            schemaname  = $schema
            displayname = $compte.Nom
            description = $compte.Description
            type        = 100000000
        } | ConvertTo-Json

        $h = $Headers.Clone()
        $h["MSCRM.SolutionUniqueName"] = $SolutionName
        $h["Prefer"] = "return=representation"
        $definitionId = (Invoke-RestMethod -Uri "$OrgUrl/api/data/v9.2/environmentvariabledefinitions" -Method Post -Headers $h -Body $body).environmentvariabledefinitionid
        Write-Host "Variable d'environnement $schema creee (type Texte, sans valeur par defaut)." -ForegroundColor Green
    }

    $valeurs = Invoke-RestMethod -Uri "$OrgUrl/api/data/v9.2/environmentvariablevalues?`$filter=_environmentvariabledefinitionid_value eq $definitionId&`$select=environmentvariablevalueid" -Headers $Headers -Method Get

    if ($valeurs.value.Count -gt 0) {
        Write-Host "Valeur courante de $schema existe deja." -ForegroundColor DarkGray
    } else {
        $userId = (Invoke-RestMethod -Uri "$OrgUrl/api/data/v9.2/WhoAmI" -Headers $Headers -Method Get).UserId
        $upn = (Invoke-RestMethod -Uri "$OrgUrl/api/data/v9.2/systemusers($userId)?`$select=domainname" -Headers $Headers -Method Get).domainname

        $body = @{
            value = $upn
            "EnvironmentVariableDefinitionId@odata.bind" = "/environmentvariabledefinitions($definitionId)"
        } | ConvertTo-Json

        Invoke-RestMethod -Uri "$OrgUrl/api/data/v9.2/environmentvariablevalues" -Method Post -Headers $Headers -Body $body | Out-Null
        Write-Host "Valeur courante de $schema definie sur le compte connecte." -ForegroundColor Green
    }
}
