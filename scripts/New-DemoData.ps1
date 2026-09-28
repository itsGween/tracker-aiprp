<#
    New-DemoData.ps1

    Genere des demandes AIPRP fictives et leur journal d'activite associe, pour demontrer
    l'application. Toutes les donnees (noms, courriels, objets de demande) sont inventees.

    Prerequis : le schema cree par New-DataverseSchema.ps1

    Utilisation :
      .\scripts\New-DemoData.ps1
#>

$ErrorActionPreference = "Stop"

$dv = & "$PSScriptRoot\Connect-Dataverse.ps1"
$OrgUrl = $dv.OrgUrl
$Headers = $dv.Headers

# Valeurs des choix (definies par New-DataverseSchema.ps1)
$TypeAcces = 100000000
$TypeRenseignements = 100000001

$StatutRecue = 100000010
$StatutEnTraitement = 100000011
$StatutProrogee = 100000012
$StatutCompletee = 100000013
$StatutFermee = 100000014

$ClassNonClassifie = 100000020
$ClassProtegeA = 100000021
$ClassProtegeB = 100000022

$ActionDemandeRecue = 100000030
$ActionChangementStatut = 100000031
$ActionCommentaireAjoute = 100000032
$ActionProrogationDemandee = 100000033
$ActionProrogationApprouvee = 100000034
$ActionFermeture = 100000035

$who = Invoke-RestMethod -Uri "$OrgUrl/api/data/v9.2/WhoAmI" -Headers $Headers -Method Get
$agentId = $who.UserId
Write-Host "Agent/auteur utilise pour les donnees de demo : $agentId (seul compte utilisateur reel de cet environnement)" -ForegroundColor Yellow

# --- Jeu de donnees fictives ---
$demandes = @(
    @{ Nom = "Amara Cloutier";          Objet = "Copie des courriels concernant le dossier de subvention 2024-118";            Type = $TypeAcces;          Jours = 2;  Statut = $StatutRecue;       Classe = $ClassNonClassifie }
    @{ Nom = "Samuel Tremblay-Nguyen";   Objet = "Dossier personnel RH - releve d'emploi";                                     Type = $TypeRenseignements; Jours = 5;  Statut = $StatutEnTraitement; Classe = $ClassProtegeA }
    @{ Nom = "Priya Chandra";            Objet = "Rapports d'inspection du site XYZ pour l'annee 2023";                        Type = $TypeAcces;          Jours = 33; Statut = $StatutEnTraitement; Classe = $ClassNonClassifie }
    @{ Nom = "Marc-Andre Belanger";      Objet = "Correspondance interne relative a la politique de teletravail";              Type = $TypeAcces;          Jours = 10; Statut = $StatutEnTraitement; Classe = $ClassNonClassifie }
    @{ Nom = "Fatima El-Amrani";         Objet = "Dossier medical soumis dans le cadre d'une demande d'accommodement";         Type = $TypeRenseignements; Jours = 27; Statut = $StatutEnTraitement; Classe = $ClassProtegeB }
    @{ Nom = "Liam O'Brien";             Objet = "Contrats de service conclus avec des fournisseurs externes en 2024";         Type = $TypeAcces;          Jours = 60; Statut = $StatutCompletee;    Classe = $ClassNonClassifie }
    @{ Nom = "Chloe Bergeron";           Objet = "Statistiques de traitement des plaintes du public";                          Type = $TypeAcces;          Jours = 15; Statut = $StatutEnTraitement; Classe = $ClassNonClassifie }
    @{ Nom = "Noah Whitehorse";          Objet = "Evaluation de rendement 2023";                                               Type = $TypeRenseignements; Jours = 70; Statut = $StatutFermee;       Classe = $ClassProtegeA }
    @{ Nom = "Aisha Diallo";             Objet = "Rapports de verification interne 2023-2024";                                 Type = $TypeAcces;          Jours = 26; Statut = $StatutProrogee;     Classe = $ClassNonClassifie; Motif = "Volume important de documents a rassembler aupres de plusieurs directions." }
    @{ Nom = "Jacob Fontaine";           Objet = "Notes de breffage preparees pour le sous-ministre";                          Type = $TypeAcces;          Jours = 1;  Statut = $StatutRecue;       Classe = $ClassProtegeA }
    @{ Nom = "Sofia Rinaldi";            Objet = "Historique des demandes de conges de maladie";                              Type = $TypeRenseignements; Jours = 42; Statut = $StatutEnTraitement; Classe = $ClassProtegeA }
    @{ Nom = "Ethan Bouchard";           Objet = "Courriels echanges concernant la restructuration du service";                Type = $TypeAcces;          Jours = 8;  Statut = $StatutEnTraitement; Classe = $ClassNonClassifie }
    @{ Nom = "Mei Lin Wong";             Objet = "Documents relatifs a une plainte en matiere de droits de la personne";       Type = $TypeRenseignements; Jours = 18; Statut = $StatutEnTraitement; Classe = $ClassProtegeB }
    @{ Nom = "Gabriel Simard";           Objet = "Notes de reunion du comite de direction, janvier a mars 2025";               Type = $TypeAcces;          Jours = 29; Statut = $StatutProrogee;     Classe = $ClassNonClassifie; Motif = "Consultation juridique requise avant divulgation." }
    @{ Nom = "Nadia Haddad";             Objet = "Correspondance relative a un contrat d'approvisionnement";                   Type = $TypeAcces;          Jours = 50; Statut = $StatutFermee;       Classe = $ClassNonClassifie }
)

$created = 0
foreach ($d in $demandes) {
    $reception = (Get-Date).AddDays(-$d.Jours).Date
    $echeanceOriginale = $reception.AddDays(30)
    $echeance = $echeanceOriginale
    $nouvelleEcheance = $null

    if ($d.Statut -eq $StatutProrogee) {
        $nouvelleEcheance = $echeanceOriginale.AddDays(15)
        $echeance = $nouvelleEcheance
    }

    $courriel = ($d.Nom.ToLower() -replace "[^a-z\- ]", "" -replace " ", ".") + "@exemple-fictif.ca"

    $body = @{
        gk_nomdemandeur          = $d.Nom
        gk_courrieldemandeur     = $courriel
        gk_objet                 = $d.Objet
        gk_type                  = $d.Type
        gk_datereception         = $reception.ToString("yyyy-MM-dd")
        gk_dateecheance          = $echeance.ToString("yyyy-MM-dd")
        gk_statut                = $d.Statut
        gk_classification        = $d.Classe
        "gk_AgentAssigneId@odata.bind" = "/systemusers($agentId)"
    }
    if ($nouvelleEcheance) {
        $body["gk_nouvelleecheanceprorogation"] = $nouvelleEcheance.ToString("yyyy-MM-dd")
        $body["gk_motifprorogation"] = $d.Motif
    }

    $json = $body | ConvertTo-Json
    $resp = Invoke-WebRequest -Uri "$OrgUrl/api/data/v9.2/gk_demandes" -Method Post -Headers $Headers -Body $json -UseBasicParsing
    $demandeId = (($resp.Headers["OData-EntityId"] -split "\(" | Select-Object -Last 1) -replace "\)$", "")

    # --- Journal d'activite ---
    $activites = @()
    $activites += @{ Date = $reception; Action = $ActionDemandeRecue; Commentaire = "Demande recue et enregistree dans le systeme." }

    if ($d.Statut -ne $StatutRecue) {
        $activites += @{ Date = $reception.AddDays(1); Action = $ActionChangementStatut; Commentaire = "Statut change a En traitement." }
    }

    if ($d.Statut -eq $StatutProrogee) {
        $activites += @{ Date = $echeanceOriginale.AddDays(-5); Action = $ActionProrogationDemandee; Commentaire = $d.Motif }
        $activites += @{ Date = $echeanceOriginale.AddDays(-4); Action = $ActionProrogationApprouvee; Commentaire = "Prorogation approuvee par la gestionnaire. Nouvelle echeance : $($nouvelleEcheance.ToString('yyyy-MM-dd'))." }
    }

    if ($d.Statut -eq $StatutCompletee -or $d.Statut -eq $StatutFermee) {
        $activites += @{ Date = $reception.AddDays(20); Action = $ActionCommentaireAjoute; Commentaire = "Reponse finale envoyee au demandeur." }
    }

    if ($d.Statut -eq $StatutFermee) {
        $activites += @{ Date = $reception.AddDays(25); Action = $ActionFermeture; Commentaire = "Dossier ferme." }
    }

    foreach ($a in $activites) {
        $actBody = @{
            gk_date                    = $a.Date.ToString("yyyy-MM-ddTHH:mm:ssZ")
            gk_action                  = $a.Action
            gk_commentaire              = $a.Commentaire
            "gk_DemandeId@odata.bind"  = "/gk_demandes($demandeId)"
            "gk_AuteurId@odata.bind"   = "/systemusers($agentId)"
        } | ConvertTo-Json
        Invoke-RestMethod -Uri "$OrgUrl/api/data/v9.2/gk_activites" -Method Post -Headers $Headers -Body $actBody | Out-Null
    }

    $created++
    Write-Host "  $($d.Nom) : demande creee avec $($activites.Count) activite(s)." -ForegroundColor Green
}

Write-Host ""
Write-Host "$created demandes fictives creees avec leur journal d'activite." -ForegroundColor Green

