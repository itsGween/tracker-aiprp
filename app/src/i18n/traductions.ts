// Traductions de l'interface (FR/EN). Reprises telles quelles de l'iteration
// canvas (docs/archive/powerfx-canvas/00-app/OnStart.fx.txt), 62 cles.
// Aucun texte de l'interface ne doit etre code en dur ailleurs que dans ce fichier.

export interface Traduction {
  fr: string;
  en: string;
}

export const traductions: Record<string, Traduction> = {
  // --- Navigation commune ---
  app_titre: { fr: "Suivi AIPRP", en: "ATIP Tracker" },
  nav_tableau_bord: { fr: "Tableau de bord", en: "Dashboard" },
  nav_liste: { fr: "Liste des demandes", en: "Request list" },
  nav_nouvelle: { fr: "Nouvelle demande", en: "New request" },
  bouton_langue: { fr: "English", en: "Français" },

  // --- Ecran 1 : Tableau de bord ---
  dashboard_titre: { fr: "Tableau de bord", en: "Dashboard" },
  dashboard_recues: { fr: "Reçues", en: "Received" },
  dashboard_entraitement: { fr: "En traitement", en: "In progress" },
  dashboard_prorogation_demandee: { fr: "Prorogation demandée", en: "Extension requested" },
  dashboard_prorogees: { fr: "Prorogées", en: "Extended" },
  dashboard_completees: { fr: "Complétées", en: "Completed" },
  dashboard_fermees: { fr: "Fermées", en: "Closed" },
  dashboard_enretard: { fr: "En retard", en: "Overdue" },
  dashboard_bientotecheance: { fr: "Échéance dans 5 jours ou moins", en: "Due within 5 days" },
  dashboard_voir_toutes: { fr: "Voir toutes les demandes", en: "View all requests" },

  // --- Ecran 2 : Liste des demandes ---
  liste_titre: { fr: "Liste des demandes", en: "Request list" },
  liste_recherche_placeholder: { fr: "Rechercher (nom, objet, numéro)", en: "Search (name, subject, number)" },
  liste_filtre_statut: { fr: "Statut", en: "Status" },
  liste_filtre_agent: { fr: "Agent assigné", en: "Assigned agent" },
  liste_tous: { fr: "Tous", en: "All" },
  liste_col_numero: { fr: "Numéro", en: "Number" },
  liste_col_demandeur: { fr: "Demandeur", en: "Requester" },
  liste_col_statut: { fr: "Statut", en: "Status" },
  liste_col_echeance: { fr: "Échéance", en: "Due date" },
  liste_col_agent: { fr: "Agent", en: "Agent" },

  // --- Ecran 3 : Detail et traitement ---
  detail_titre: { fr: "Détail de la demande", en: "Request details" },
  detail_type: { fr: "Type", en: "Type" },
  detail_demandeur: { fr: "Demandeur", en: "Requester" },
  detail_courriel: { fr: "Courriel", en: "Email" },
  detail_objet: { fr: "Objet", en: "Subject" },
  detail_reception: { fr: "Date de réception", en: "Date received" },
  detail_echeance: { fr: "Date d'échéance", en: "Due date" },
  detail_statut: { fr: "Statut", en: "Status" },
  detail_classification: { fr: "Classification", en: "Classification" },
  detail_agent: { fr: "Agent assigné", en: "Assigned agent" },
  detail_activites: { fr: "Journal d'activité", en: "Activity log" },
  detail_ajouter_commentaire: { fr: "Ajouter un commentaire", en: "Add a comment" },
  detail_demander_prorogation: { fr: "Demander une prorogation", en: "Request an extension" },
  detail_motif_prorogation: { fr: "Motif de la prorogation", en: "Extension reason" },
  detail_approuver_prorogation: { fr: "Approuver la prorogation", en: "Approve extension" },
  detail_prorogation_en_attente: {
    fr: "Prorogation en attente d'approbation (flux Power Automate)",
    en: "Extension pending approval (Power Automate flow)",
  },
  detail_enregistrer: { fr: "Enregistrer", en: "Save" },
  detail_retour: { fr: "Retour", en: "Back" },

  // --- Ecran 4 : Nouvelle demande ---
  nouvelle_titre: { fr: "Nouvelle demande AIPRP", en: "New ATIP request" },
  nouvelle_type: { fr: "Type de demande", en: "Request type" },
  nouvelle_nomdemandeur: { fr: "Nom du demandeur", en: "Requester name" },
  nouvelle_courriel: { fr: "Courriel du demandeur", en: "Requester email" },
  nouvelle_objet: { fr: "Objet de la demande", en: "Request subject" },
  nouvelle_reception: { fr: "Date de réception", en: "Date received" },
  nouvelle_classification: { fr: "Classification", en: "Classification" },
  nouvelle_soumettre: { fr: "Soumettre", en: "Submit" },
  nouvelle_annuler: { fr: "Annuler", en: "Cancel" },
  nouvelle_erreur_champs: { fr: "Veuillez remplir tous les champs obligatoires.", en: "Please fill in all required fields." },
  nouvelle_succes: { fr: "Demande créée avec succès.", en: "Request created successfully." },

  // --- Valeurs des choix Dataverse (cle = valeur numerique du choix) ---
  choix_100000000: { fr: "Accès à l'information", en: "Access to information" },
  choix_100000001: { fr: "Renseignements personnels", en: "Personal information" },
  choix_100000010: { fr: "Reçue", en: "Received" },
  choix_100000011: { fr: "En traitement", en: "In progress" },
  choix_100000012: { fr: "Prorogée", en: "Extended" },
  choix_100000015: { fr: "Prorogation demandée", en: "Extension requested" },
  choix_100000013: { fr: "Complétée", en: "Completed" },
  choix_100000014: { fr: "Fermée", en: "Closed" },
  choix_100000020: { fr: "Non classifié", en: "Unclassified" },
  choix_100000021: { fr: "Protégé A", en: "Protected A" },
  choix_100000022: { fr: "Protégé B", en: "Protected B" },

  // --- Valeurs des choix Dataverse - gk_activite.gk_action ---
  choix_100000030: { fr: "Demande reçue", en: "Request received" },
  choix_100000031: { fr: "Changement de statut", en: "Status change" },
  choix_100000032: { fr: "Commentaire ajouté", en: "Comment added" },
  choix_100000033: { fr: "Prorogation demandée", en: "Extension requested" },
  choix_100000034: { fr: "Prorogation approuvée", en: "Extension approved" },
  choix_100000035: { fr: "Fermeture", en: "Closure" },
};
