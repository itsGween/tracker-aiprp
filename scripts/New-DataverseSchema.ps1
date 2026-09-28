<#
    New-DataverseSchema.ps1

    Cree le schema Dataverse du projet Suivi AIPRP :
      - editeur (publisher) prefixe gk
      - solution SuiviAIPRP
      - table gk_demande (Demande AIPRP)
      - table gk_activite (journal lie a une demande)
      - relations 1:N (gk_demande -> gk_activite, systemuser -> agent assigne, systemuser -> auteur)

    Idempotent : les elements deja presents sont detectes et ignores, le script peut etre relance
    sans dupliquer quoi que ce soit.

    Utilisation :
      .\scripts\New-DataverseSchema.ps1
#>

$ErrorActionPreference = "Stop"

$dv = & "$PSScriptRoot\Connect-Dataverse.ps1"
$OrgUrl = $dv.OrgUrl
$Headers = $dv.Headers
$SolutionName = "SuiviAIPRP"

function New-Label {
    param([string]$Text)
    @{
        "@odata.type"       = "Microsoft.Dynamics.CRM.Label"
        LocalizedLabels     = @(
            @{
                "@odata.type" = "Microsoft.Dynamics.CRM.LocalizedLabel"
                Label         = $Text
                LanguageCode  = 1033
            }
        )
        UserLocalizedLabel  = @{
            "@odata.type" = "Microsoft.Dynamics.CRM.LocalizedLabel"
            Label         = $Text
            LanguageCode  = 1033
        }
    }
}

function New-RequiredLevel {
    param([string]$Value = "None")
    @{ Value = $Value; CanBeChanged = $true; ManagedPropertyLogicalName = "canmodifyrequirementlevelsettings" }
}

function New-StringAttribute {
    param(
        [string]$SchemaName, [string]$DisplayName, [string]$Description,
        [int]$MaxLength = 100, [string]$Format = "Text",
        [string]$AutoNumberFormat = $null, [switch]$IsPrimaryName, [string]$RequiredLevel = "None"
    )
    $attr = [ordered]@{
        "@odata.type"      = "Microsoft.Dynamics.CRM.StringAttributeMetadata"
        AttributeType      = "String"
        AttributeTypeName  = @{ Value = "StringType" }
        SchemaName         = $SchemaName
        MaxLength          = $MaxLength
        FormatName         = @{ Value = $Format }
        DisplayName        = New-Label $DisplayName
        Description        = New-Label $Description
        RequiredLevel      = New-RequiredLevel $RequiredLevel
    }
    if ($IsPrimaryName) { $attr["IsPrimaryName"] = $true }
    if ($AutoNumberFormat) { $attr["AutoNumberFormat"] = $AutoNumberFormat }
    $attr
}

function New-MemoAttribute {
    param([string]$SchemaName, [string]$DisplayName, [string]$Description, [int]$MaxLength = 2000)
    @{
        "@odata.type"     = "Microsoft.Dynamics.CRM.MemoAttributeMetadata"
        AttributeType     = "Memo"
        AttributeTypeName = @{ Value = "MemoType" }
        Format            = "TextArea"
        MaxLength         = $MaxLength
        SchemaName        = $SchemaName
        DisplayName       = New-Label $DisplayName
        Description       = New-Label $Description
        RequiredLevel     = New-RequiredLevel
    }
}

function New-DateTimeAttribute {
    param([string]$SchemaName, [string]$DisplayName, [string]$Description, [string]$RequiredLevel = "None", [switch]$WithTime)
    $format = if ($WithTime) { "DateAndTime" } else { "DateOnly" }
    $behavior = if ($WithTime) { "UserLocal" } else { "DateOnly" }
    @{
        "@odata.type"      = "Microsoft.Dynamics.CRM.DateTimeAttributeMetadata"
        AttributeType      = "DateTime"
        AttributeTypeName  = @{ Value = "DateTimeType" }
        Format             = $format
        DateTimeBehavior   = @{ Value = $behavior }
        SchemaName         = $SchemaName
        DisplayName        = New-Label $DisplayName
        Description        = New-Label $Description
        RequiredLevel      = New-RequiredLevel $RequiredLevel
    }
}

function New-PicklistAttribute {
    param([string]$SchemaName, [string]$DisplayName, [string]$Description, [string[]]$Options, [int]$OptionBaseValue, [int]$DefaultIndex = -1)
    $opts = @()
    for ($i = 0; $i -lt $Options.Count; $i++) {
        $opts += @{ Value = $OptionBaseValue + $i; Label = (New-Label $Options[$i]) }
    }
    $attr = [ordered]@{
        "@odata.type"     = "Microsoft.Dynamics.CRM.PicklistAttributeMetadata"
        AttributeType     = "Picklist"
        AttributeTypeName = @{ Value = "PicklistType" }
        OptionSet         = @{
            "@odata.type"  = "Microsoft.Dynamics.CRM.OptionSetMetadata"
            IsGlobal       = $false
            OptionSetType  = "Picklist"
            Options        = $opts
        }
        SchemaName    = $SchemaName
        DisplayName   = New-Label $DisplayName
        Description   = New-Label $Description
        RequiredLevel = New-RequiredLevel
    }
    if ($DefaultIndex -ge 0) { $attr["DefaultFormValue"] = $OptionBaseValue + $DefaultIndex }
    $attr
}

function Test-EntityExists {
    param([string]$LogicalName)
    try {
        Invoke-RestMethod -Uri "$OrgUrl/api/data/v9.2/EntityDefinitions(LogicalName='$LogicalName')?`$select=LogicalName" -Headers $Headers -Method Get | Out-Null
        return $true
    } catch {
        return $false
    }
}

function Test-AttributeExists {
    param([string]$EntityLogicalName, [string]$AttributeLogicalName)
    try {
        Invoke-RestMethod -Uri "$OrgUrl/api/data/v9.2/EntityDefinitions(LogicalName='$EntityLogicalName')/Attributes(LogicalName='$AttributeLogicalName')?`$select=LogicalName" -Headers $Headers -Method Get | Out-Null
        return $true
    } catch {
        return $false
    }
}

function Test-RelationshipExists {
    param([string]$SchemaName)
    try {
        Invoke-RestMethod -Uri "$OrgUrl/api/data/v9.2/RelationshipDefinitions(SchemaName='$SchemaName')?`$select=SchemaName" -Headers $Headers -Method Get | Out-Null
        return $true
    } catch {
        return $false
    }
}

function Add-Column {
    param([string]$EntityLogicalName, [hashtable]$Attribute, [string]$Label)
    $logicalName = $Attribute.SchemaName.ToLower()
    if (Test-AttributeExists -EntityLogicalName $EntityLogicalName -AttributeLogicalName $logicalName) {
        Write-Host "  - $Label ($logicalName) existe deja, ignore." -ForegroundColor DarkGray
        return
    }
    $h = $Headers.Clone()
    $h["MSCRM.SolutionUniqueName"] = $SolutionName
    $json = $Attribute | ConvertTo-Json -Depth 20
    Invoke-RestMethod -Uri "$OrgUrl/api/data/v9.2/EntityDefinitions(LogicalName='$EntityLogicalName')/Attributes" -Method Post -Headers $h -Body $json | Out-Null
    Write-Host "  - $Label ($logicalName) cree." -ForegroundColor Green
}

# --- 1. Editeur (publisher) ---
Write-Host "1. Editeur..." -ForegroundColor Cyan
$publisherUniqueName = "gweenkangahaiprp"
$publisher = Invoke-RestMethod -Uri "$OrgUrl/api/data/v9.2/publishers?`$filter=uniquename eq '$publisherUniqueName'&`$select=publisherid" -Headers $Headers -Method Get
if ($publisher.value.Count -gt 0) {
    $publisherId = $publisher.value[0].publisherid
    Write-Host "  Editeur existant : $publisherId" -ForegroundColor DarkGray
} else {
    $body = @{
        friendlyname                    = "Gween Kangah - AIPRP"
        uniquename                      = $publisherUniqueName
        description                     = "Editeur du projet de demonstration Suivi AIPRP"
        customizationprefix             = "gk"
        customizationoptionvalueprefix  = 10000
    } | ConvertTo-Json
    $resp = Invoke-WebRequest -Uri "$OrgUrl/api/data/v9.2/publishers" -Method Post -Headers $Headers -Body $body -UseBasicParsing
    $publisherId = ($resp.Headers["OData-EntityId"] -split "\(" | Select-Object -Last 1) -replace "\)$", ""
    Write-Host "  Editeur cree : $publisherId" -ForegroundColor Green
}

# --- 2. Solution ---
Write-Host "2. Solution..." -ForegroundColor Cyan
$solution = Invoke-RestMethod -Uri "$OrgUrl/api/data/v9.2/solutions?`$filter=uniquename eq '$SolutionName'&`$select=solutionid" -Headers $Headers -Method Get
if ($solution.value.Count -gt 0) {
    Write-Host "  Solution existante." -ForegroundColor DarkGray
} else {
    $body = @{
        friendlyname            = "Suivi AIPRP"
        uniquename              = $SolutionName
        description              = "Suivi des demandes AIPRP - projet de demonstration"
        version                  = "1.0.0.0"
        "publisherid@odata.bind" = "publishers($publisherId)"
    } | ConvertTo-Json
    Invoke-RestMethod -Uri "$OrgUrl/api/data/v9.2/solutions" -Method Post -Headers $Headers -Body $body | Out-Null
    Write-Host "  Solution creee." -ForegroundColor Green
}

# --- 3. Table gk_demande ---
Write-Host "3. Table gk_demande..." -ForegroundColor Cyan
if (Test-EntityExists -LogicalName "gk_demande") {
    Write-Host "  Table existante, ignoree." -ForegroundColor DarkGray
} else {
    $primaryAttr = New-StringAttribute -SchemaName "gk_name" -DisplayName "Numero de la demande" `
        -Description "Numero genere automatiquement, format A-AAAA-00000" -MaxLength 100 `
        -AutoNumberFormat "A-{DATETIMEUTC:yyyy}-{SEQNUM:5}" -IsPrimaryName

    $body = @{
        "@odata.type"          = "Microsoft.Dynamics.CRM.EntityMetadata"
        SchemaName             = "gk_demande"
        DisplayName            = New-Label "Demande AIPRP"
        DisplayCollectionName  = New-Label "Demandes AIPRP"
        Description            = New-Label "Demande d'acces a l'information ou de renseignements personnels."
        OwnershipType          = "UserOwned"
        HasActivities          = $false
        HasNotes               = $false
        IsActivity             = $false
        PrimaryNameAttribute   = "gk_name"
        Attributes             = @($primaryAttr)
    } | ConvertTo-Json -Depth 20

    $h = $Headers.Clone()
    $h["MSCRM.SolutionUniqueName"] = $SolutionName
    Invoke-RestMethod -Uri "$OrgUrl/api/data/v9.2/EntityDefinitions" -Method Post -Headers $h -Body $body | Out-Null
    Write-Host "  Table creee." -ForegroundColor Green
}

Write-Host "  Colonnes de gk_demande..." -ForegroundColor Cyan
Add-Column -EntityLogicalName "gk_demande" -Label "Type de demande" -Attribute (New-PicklistAttribute `
    -SchemaName "gk_type" -DisplayName "Type de demande" -Description "Type de demande AIPRP" `
    -Options @("Acces a l'information", "Renseignements personnels") -OptionBaseValue 100000000)

Add-Column -EntityLogicalName "gk_demande" -Label "Nom du demandeur" -Attribute (New-StringAttribute `
    -SchemaName "gk_nomdemandeur" -DisplayName "Nom du demandeur" -Description "Nom complet du demandeur (donnee fictive)" `
    -MaxLength 200 -RequiredLevel "ApplicationRequired")

Add-Column -EntityLogicalName "gk_demande" -Label "Courriel du demandeur" -Attribute (New-StringAttribute `
    -SchemaName "gk_courrieldemandeur" -DisplayName "Courriel du demandeur" -Description "Courriel du demandeur (donnee fictive)" `
    -MaxLength 200 -Format "Email")

Add-Column -EntityLogicalName "gk_demande" -Label "Objet" -Attribute (New-MemoAttribute `
    -SchemaName "gk_objet" -DisplayName "Objet de la demande" -Description "Description de l'objet de la demande" -MaxLength 2000)

Add-Column -EntityLogicalName "gk_demande" -Label "Date de reception" -Attribute (New-DateTimeAttribute `
    -SchemaName "gk_datereception" -DisplayName "Date de reception" -Description "Date de reception de la demande" -RequiredLevel "ApplicationRequired")

Add-Column -EntityLogicalName "gk_demande" -Label "Date d'echeance" -Attribute (New-DateTimeAttribute `
    -SchemaName "gk_dateecheance" -DisplayName "Date d'echeance" `
    -Description "Reception + 30 jours, fixee par le flux Demande recue puis mise a jour par le flux de prorogation.")

Add-Column -EntityLogicalName "gk_demande" -Label "Statut" -Attribute (New-PicklistAttribute `
    -SchemaName "gk_statut" -DisplayName "Statut" -Description "Statut courant de la demande" `
    -Options @("Recue", "En traitement", "Prorogee", "Completee", "Fermee") -OptionBaseValue 100000010 -DefaultIndex 0)

Add-Column -EntityLogicalName "gk_demande" -Label "Classification" -Attribute (New-PicklistAttribute `
    -SchemaName "gk_classification" -DisplayName "Classification" -Description "Niveau de classification de la demande" `
    -Options @("Non classifie", "Protege A", "Protege B") -OptionBaseValue 100000020 -DefaultIndex 0)

Add-Column -EntityLogicalName "gk_demande" -Label "Motif de prorogation" -Attribute (New-MemoAttribute `
    -SchemaName "gk_motifprorogation" -DisplayName "Motif de prorogation" -Description "Motif de la demande de prorogation" -MaxLength 2000)

Add-Column -EntityLogicalName "gk_demande" -Label "Nouvelle echeance de prorogation" -Attribute (New-DateTimeAttribute `
    -SchemaName "gk_nouvelleecheanceprorogation" -DisplayName "Nouvelle echeance (prorogation)" `
    -Description "Nouvelle date d'echeance proposee en cas de prorogation")

# --- 4. Table gk_activite ---
Write-Host "4. Table gk_activite..." -ForegroundColor Cyan
if (Test-EntityExists -LogicalName "gk_activite") {
    Write-Host "  Table existante, ignoree." -ForegroundColor DarkGray
} else {
    $primaryAttr = New-StringAttribute -SchemaName "gk_name" -DisplayName "Numero de l'activite" `
        -Description "Numero genere automatiquement, format ACT-00000" -MaxLength 100 `
        -AutoNumberFormat "ACT-{SEQNUM:5}" -IsPrimaryName

    $body = @{
        "@odata.type"          = "Microsoft.Dynamics.CRM.EntityMetadata"
        SchemaName             = "gk_activite"
        DisplayName            = New-Label "Activite"
        DisplayCollectionName  = New-Label "Activites"
        Description            = New-Label "Journal d'activite lie a une demande AIPRP."
        OwnershipType          = "UserOwned"
        HasActivities          = $false
        HasNotes               = $false
        IsActivity             = $false
        PrimaryNameAttribute   = "gk_name"
        Attributes             = @($primaryAttr)
    } | ConvertTo-Json -Depth 20

    $h = $Headers.Clone()
    $h["MSCRM.SolutionUniqueName"] = $SolutionName
    Invoke-RestMethod -Uri "$OrgUrl/api/data/v9.2/EntityDefinitions" -Method Post -Headers $h -Body $body | Out-Null
    Write-Host "  Table creee." -ForegroundColor Green
}

Write-Host "  Colonnes de gk_activite..." -ForegroundColor Cyan
Add-Column -EntityLogicalName "gk_activite" -Label "Date" -Attribute (New-DateTimeAttribute `
    -SchemaName "gk_date" -DisplayName "Date de l'activite" -Description "Date et heure de l'activite" -RequiredLevel "ApplicationRequired" -WithTime)

Add-Column -EntityLogicalName "gk_activite" -Label "Action" -Attribute (New-PicklistAttribute `
    -SchemaName "gk_action" -DisplayName "Action" -Description "Type d'action journalisee" `
    -Options @("Demande recue", "Changement de statut", "Commentaire ajoute", "Prorogation demandee", "Prorogation approuvee", "Fermeture") `
    -OptionBaseValue 100000030)

Add-Column -EntityLogicalName "gk_activite" -Label "Commentaire" -Attribute (New-MemoAttribute `
    -SchemaName "gk_commentaire" -DisplayName "Commentaire" -Description "Commentaire libre associe a l'activite" -MaxLength 2000)

# --- 5. Relations ---
Write-Host "5. Relations..." -ForegroundColor Cyan

function New-Relationship {
    param(
        [string]$RelationshipSchemaName, [string]$ReferencedEntity, [string]$ReferencingEntity,
        [string]$LookupSchemaName, [string]$LookupDisplayName, [string]$LookupDescription, [string]$Label
    )
    if (Test-RelationshipExists -SchemaName $RelationshipSchemaName) {
        Write-Host "  - $Label existe deja, ignoree." -ForegroundColor DarkGray
        return
    }
    $body = @{
        "@odata.type"     = "Microsoft.Dynamics.CRM.OneToManyRelationshipMetadata"
        SchemaName        = $RelationshipSchemaName
        ReferencedEntity  = $ReferencedEntity
        ReferencingEntity = $ReferencingEntity
        RelationshipType  = "OneToManyRelationship"
        IsCustomRelationship     = $true
        IsManaged                = $false
        IsValidForAdvancedFind   = $true
        SecurityTypes            = "None"
        IsHierarchical           = $false
        AssociatedMenuConfiguration = @{ Behavior = "UseCollectionName"; Group = "Details"; Order = 10000 }
        CascadeConfiguration = @{
            Assign = "NoCascade"; Delete = "RemoveLink"; Merge = "NoCascade"
            Reparent = "NoCascade"; Share = "NoCascade"; Unshare = "NoCascade"
        }
        Lookup = @{
            "@odata.type"     = "Microsoft.Dynamics.CRM.LookupAttributeMetadata"
            AttributeType     = "Lookup"
            AttributeTypeName = @{ Value = "LookupType" }
            SchemaName        = $LookupSchemaName
            DisplayName       = New-Label $LookupDisplayName
            Description       = New-Label $LookupDescription
            RequiredLevel     = New-RequiredLevel
        }
    } | ConvertTo-Json -Depth 20

    $h = $Headers.Clone()
    $h["MSCRM.SolutionUniqueName"] = $SolutionName
    Invoke-RestMethod -Uri "$OrgUrl/api/data/v9.2/RelationshipDefinitions" -Method Post -Headers $h -Body $body | Out-Null
    Write-Host "  - $Label creee." -ForegroundColor Green
}

New-Relationship -RelationshipSchemaName "gk_demande_activites" `
    -ReferencedEntity "gk_demande" -ReferencingEntity "gk_activite" `
    -LookupSchemaName "gk_DemandeId" -LookupDisplayName "Demande" -LookupDescription "Demande AIPRP liee a cette activite" `
    -Label "gk_demande -> gk_activite"

New-Relationship -RelationshipSchemaName "gk_systemuser_demandes_agent" `
    -ReferencedEntity "systemuser" -ReferencingEntity "gk_demande" `
    -LookupSchemaName "gk_AgentAssigneId" -LookupDisplayName "Agent assigne" -LookupDescription "Agent ou agente AIPRP assigne a cette demande" `
    -Label "systemuser -> gk_demande (agent assigne)"

New-Relationship -RelationshipSchemaName "gk_systemuser_activites_auteur" `
    -ReferencedEntity "systemuser" -ReferencingEntity "gk_activite" `
    -LookupSchemaName "gk_AuteurId" -LookupDisplayName "Auteur" -LookupDescription "Utilisateur ou utilisatrice a l'origine de cette activite" `
    -Label "systemuser -> gk_activite (auteur)"

# --- 6. Publication ---
Write-Host "6. Publication des personnalisations..." -ForegroundColor Cyan
Invoke-RestMethod -Uri "$OrgUrl/api/data/v9.2/PublishAllXml" -Method Post -Headers $Headers -Body "{}" | Out-Null
Write-Host "  Publie." -ForegroundColor Green

Write-Host ""
Write-Host "Schema Dataverse cree avec succes." -ForegroundColor Green
