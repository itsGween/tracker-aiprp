<#
    Update-Flux.ps1

    Met a jour un flux existant a partir de sa definition dans src/flows/. Un flux active est
    desactive pendant la mise a jour, puis reactive. La definition relue dans Dataverse est
    ensuite comparee au fichier.

    Par defaut, simule : valide la definition, sans rien ecrire.

    Utilisation :
      .\scripts\Update-Flux.ps1 -Nom "Rappel quotidien des echeances" -Fichier rappel-quotidien-echeances.json
      .\scripts\Update-Flux.ps1 -Nom "..." -Fichier ... -Appliquer
#>
param(
    [Parameter(Mandatory)][string]$Nom,
    [Parameter(Mandatory)][string]$Fichier,
    [switch]$Appliquer
)

$ErrorActionPreference = "Stop"

$dv = & "$PSScriptRoot\Connect-Dataverse.ps1"
$Api = "$($dv.OrgUrl)/api/data/v9.2"
$Headers = $dv.Headers

$chemin = Join-Path $PSScriptRoot "..\src\flows\$Fichier"
$clientdata = [IO.File]::ReadAllText((Resolve-Path $chemin), [Text.Encoding]::UTF8)

# Garde-fou : ni adresse, ni GUID hors des identifiants internes du concepteur.
$sansLiaison = $clientdata -replace '@odata\.bind', ''
if ($sansLiaison -match '[A-Za-z0-9._%+-]+@[A-Za-z0-9-]+\.[a-z]{2,}') { throw "La definition contient une adresse." }
if ($clientdata -match 'ADRESSE RETIREE') { throw "La definition contient encore le texte de remplacement de l'adresse." }
$sansMetadata = $clientdata -replace '"operationMetadataId":\s*"[^"]+"', ''
if ($sansMetadata -match '[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}') { throw "La definition contient un GUID." }
Write-Host "Definition valide : ni adresse ni GUID." -ForegroundColor Green

$flux = @((Invoke-RestMethod -Uri "$Api/workflows?`$filter=category eq 5 and type eq 1&`$select=workflowid,name,statecode" -Headers $Headers).value | Where-Object { $_.name -eq $Nom })
if ($flux.Count -ne 1) { throw "Attendu 1 flux nomme '$Nom', trouve $($flux.Count)." }

if (-not $Appliquer) {
    Write-Host "[simulation] Flux '$Nom' trouve (statecode $($flux[0].statecode)). Rien n'a ete modifie." -ForegroundColor Yellow
    return
}

$uri = "$Api/workflows($($flux[0].workflowid))"
$actif = $flux[0].statecode -eq 1
if ($actif) {
    Invoke-WebRequest -Uri $uri -Method Patch -Headers $Headers -Body (@{ statecode = 0; statuscode = 1 } | ConvertTo-Json) -ContentType "application/json" -UseBasicParsing | Out-Null
}
$corps = @{ clientdata = $clientdata } | ConvertTo-Json -Depth 3
Invoke-WebRequest -Uri $uri -Method Patch -Headers $Headers -Body ([Text.Encoding]::UTF8.GetBytes($corps)) -ContentType "application/json" -UseBasicParsing | Out-Null
if ($actif) {
    Invoke-WebRequest -Uri $uri -Method Patch -Headers $Headers -Body (@{ statecode = 1; statuscode = 2 } | ConvertTo-Json) -ContentType "application/json" -UseBasicParsing | Out-Null
}

$relu = Invoke-RestMethod -Uri "$uri`?`$select=statecode,statuscode,clientdata" -Headers $Headers
$attendu = $clientdata | ConvertFrom-Json | ConvertTo-Json -Depth 40 -Compress
$lu = $relu.clientdata | ConvertFrom-Json | ConvertTo-Json -Depth 40 -Compress
if ($attendu -ne $lu) { throw "La definition relue differe du fichier." }
Write-Host "Flux '$Nom' mis a jour : definition identique, statecode $($relu.statecode)." -ForegroundColor Green
