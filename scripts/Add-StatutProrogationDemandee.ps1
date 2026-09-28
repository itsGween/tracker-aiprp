<#
    Add-StatutProrogationDemandee.ps1

    Ajoute la valeur de choix "Prorogation demandee" (100000015) a la colonne gk_statut
    de gk_demande. Necessaire pour separer "prorogation demandee" (en attente du flux
    d'approbation) de "Prorogee" (qui signifie desormais "prorogation approuvee, en vigueur") -
    voir docs/adr/0003-approbation-prorogation-par-flux.md.

    Idempotent : verifie si l'option existe deja avant de l'ajouter.

    Utilisation :
      .\scripts\Add-StatutProrogationDemandee.ps1
#>

$ErrorActionPreference = "Stop"

$dv = & "$PSScriptRoot\Connect-Dataverse.ps1"
$OrgUrl = $dv.OrgUrl
$Headers = $dv.Headers
$SolutionName = "SuiviAIPRP"

$nouvelleValeur = 100000015

$optionSet = Invoke-RestMethod -Uri "$OrgUrl/api/data/v9.2/EntityDefinitions(LogicalName='gk_demande')/Attributes(LogicalName='gk_statut')/Microsoft.Dynamics.CRM.PicklistAttributeMetadata?`$select=SchemaName&`$expand=OptionSet" -Headers $Headers -Method Get

$dejaPresent = $optionSet.OptionSet.Options | Where-Object { $_.Value -eq $nouvelleValeur }

if ($dejaPresent) {
    Write-Host "La valeur $nouvelleValeur (Prorogation demandee) existe deja sur gk_statut." -ForegroundColor DarkGray
} else {
    $body = @{
        AttributeLogicalName = "gk_statut"
        EntityLogicalName    = "gk_demande"
        Value                = $nouvelleValeur
        Label                = @{
            "@odata.type" = "Microsoft.Dynamics.CRM.Label"
            LocalizedLabels = @(
                @{ "@odata.type" = "Microsoft.Dynamics.CRM.LocalizedLabel"; Label = "Prorogation demandee"; LanguageCode = 1036 }
            )
            UserLocalizedLabel = @{ "@odata.type" = "Microsoft.Dynamics.CRM.LocalizedLabel"; Label = "Prorogation demandee"; LanguageCode = 1036 }
        }
        SolutionUniqueName = $SolutionName
    } | ConvertTo-Json -Depth 10

    Invoke-RestMethod -Uri "$OrgUrl/api/data/v9.2/InsertOptionValue" -Method Post -Headers $Headers -Body $body | Out-Null
    Write-Host "Valeur $nouvelleValeur (Prorogation demandee) ajoutee a gk_statut." -ForegroundColor Green

    Invoke-RestMethod -Uri "$OrgUrl/api/data/v9.2/PublishAllXml" -Method Post -Headers $Headers -Body "{}" | Out-Null
    Write-Host "Publie." -ForegroundColor Green
}
