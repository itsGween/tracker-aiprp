<#
    New-FluxProrogation.ps1

    Cree le flux "Approbation de prorogation" a partir de src/flows/approbation-prorogation.json,
    dans la solution SuiviAIPRP. Methode documentee par Microsoft : POST sur la table workflows,
    category 5. Le flux est cree desactive (statecode 0).

    Par defaut, simule : valide la definition et ses prerequis, sans rien ecrire.

    Idempotent : ne cree rien si un flux du meme nom existe deja.

    Utilisation :
      .\scripts\New-FluxProrogation.ps1           # simulation
      .\scripts\New-FluxProrogation.ps1 -Creer
#>
param(
    [switch]$Creer
)

$ErrorActionPreference = "Stop"

$dv = & "$PSScriptRoot\Connect-Dataverse.ps1"
$Api = "$($dv.OrgUrl)/api/data/v9.2"
$Headers = $dv.Headers
$SolutionName = "SuiviAIPRP"
$NomFlux = "Approbation de prorogation"

$cheminDefinition = Join-Path $PSScriptRoot "..\src\flows\approbation-prorogation.json"
$clientdata = [IO.File]::ReadAllText((Resolve-Path $cheminDefinition), [Text.Encoding]::UTF8)
$definition = $clientdata | ConvertFrom-Json

# Garde-fou : la definition versionnee ne doit contenir ni adresse ni identifiant.
$sansLiaison = $clientdata -replace '@odata\.bind', ''
if ($sansLiaison -match '[A-Za-z0-9._%+-]+@[A-Za-z0-9-]+\.[a-z]{2,}') { throw "La definition contient une adresse." }
if ($clientdata -match '[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}') { throw "La definition contient un GUID." }
Write-Host "Definition valide : ni adresse ni GUID." -ForegroundColor Green

# Prerequis : references de connexion et variable d'environnement.
foreach ($r in $definition.properties.connectionReferences.PSObject.Properties) {
    $nom = $r.Value.connection.connectionReferenceLogicalName
    $trouve = (Invoke-RestMethod -Uri "$Api/connectionreferences?`$filter=connectionreferencelogicalname eq '$nom'&`$select=connectionreferenceid" -Headers $Headers).value
    if (-not $trouve) { throw "Reference de connexion introuvable : $nom" }
    Write-Host "Reference de connexion presente : $nom" -ForegroundColor Green
}
$variable = (Invoke-RestMethod -Uri "$Api/environmentvariabledefinitions?`$filter=schemaname eq 'gk_ApprobateurProrogation'&`$select=schemaname" -Headers $Headers).value
if (-not $variable) { throw "Variable d'environnement gk_ApprobateurProrogation introuvable." }
Write-Host "Variable d'environnement presente : gk_ApprobateurProrogation" -ForegroundColor Green

$existant = (Invoke-RestMethod -Uri "$Api/workflows?`$filter=category eq 5 and type eq 1 and name eq '$NomFlux'&`$select=workflowid" -Headers $Headers).value
if ($existant) {
    Write-Host "Le flux '$NomFlux' existe deja, rien a faire." -ForegroundColor DarkGray
    return
}

$corps = @{
    category      = 5
    name          = $NomFlux
    type          = 1
    description   = "Approuve ou rejette une demande de prorogation. Voir docs/adr/0003-approbation-prorogation-par-flux.md."
    primaryentity = "none"
    clientdata    = $clientdata
} | ConvertTo-Json -Depth 3

if (-not $Creer) {
    Write-Host "[simulation] POST $($Api -replace '^https://[^/]+', '[URL de l''organisation]')/workflows" -ForegroundColor Yellow
    Write-Host "[simulation] En-tete MSCRM.SolutionUniqueName: $SolutionName" -ForegroundColor Yellow
    Write-Host "[simulation] Corps : $([Text.Encoding]::UTF8.GetByteCount($corps)) octets. Rien n'a ete cree." -ForegroundColor Yellow
    return
}

$h = $Headers.Clone()
$h["MSCRM.SolutionUniqueName"] = $SolutionName
$reponse = Invoke-WebRequest -Uri "$Api/workflows" -Method Post -Headers $h -Body ([Text.Encoding]::UTF8.GetBytes($corps)) -UseBasicParsing
Write-Host "Flux '$NomFlux' cree et desactive (HTTP $($reponse.StatusCode))." -ForegroundColor Green
