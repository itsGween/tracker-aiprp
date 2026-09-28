# Flux Power Automate

⚠️ **Ces flux doivent être construits dans le portail Power Automate** (make.powerautomate.com,
même environnement Dataverse que l'app). Je ne peux pas cliquer dans le portail — ce document donne
les instructions précises, étape par étape, à suivre toi-même. Les 3 flux doivent faire partie de la
solution **Suivi AIPRP** (pas de « My flows » / solution par défaut).

## Limite de licence — pas d'Exchange/Outlook

Le tenant de développement n'a pas de boîte aux lettres. Deux cas de figure très différents :

- **Notifier un agent ou une gestionnaire** (utilisateur·rice Power Platform interne) : possible
  sans Exchange, via le connecteur **Notifications** (push Power Apps / Power Automate). Utilisé
  dans les flux 2 et 3.
- **Envoyer un accusé de réception au demandeur externe** (courriel fictif comme
  `amara.cloutier@exemple-fictif.ca`) : **impossible avec ou sans licence**, puisque ce n'est pas un
  compte Power Platform — aucun connecteur de notification interne ne peut l'atteindre. Le flux 1
  tente quand même un vrai courriel (Office 365 Outlook), avec gestion d'erreur, pour rester réaliste
  et démontrable — voir plus bas.

## Variable d'environnement `gk_EnvoiCourrielActif`

Déjà créée par script (`scripts/New-EnvironmentVariable.ps1`) : type Booléen, valeur par défaut
**false** dans cet environnement. Le flux 1 la consulte pour décider d'essayer ou non l'envoi de
courriel, sans qu'on ait à modifier le flux si un jour cet environnement (ou un autre) obtient une
vraie boîte aux lettres — il suffira de changer la valeur de la variable à `true`.

---

## Flux 1 — Demande reçue (accusé de réception conditionnel)

**Important** : l'app crée déjà la demande, calcule l'échéance et journalise « Demande reçue »
(Phase 2). Ce flux s'occupe **seulement** de l'accusé de réception par courriel — pas de doublon.

1. Dans [make.powerautomate.com](https://make.powerautomate.com), sélectionne l'environnement de
   développement, puis **Solutions** > **Suivi AIPRP** > **Nouveau** > **Automatisation** > **Flux
   cloud** > **Automatisé**.
2. Nom du flux : `Demande reçue - accusé de réception`.
3. Déclencheur : cherche **Microsoft Dataverse** > **Lorsqu'une ligne est ajoutée, modifiée ou
   supprimée**.
   - **Modifier les lignes de** : *Ajoutée*
   - **Table** : Demande AIPRP
   - **Portée** : Organisation
4. Ajoute une étape **Condition** (nomme-la « Envoi de courriel actif ? ») :
   - Clique dans le champ de gauche, onglet **Expression**, colle :
     `environmentVariables('gk_EnvoiCourrielActif')`
   - Opérateur : **est égal à**
   - Valeur de droite : `true`
5. **Branche SI OUI** :
   1. Ajoute **Office 365 Outlook** > **Envoyer un courriel (V2)**.
      - À : contenu dynamique **Courriel du demandeur** (`gk_courrieldemandeur`)
      - Objet : `Accusé de réception - Demande` (contenu dynamique **Numéro** à la suite)
      - Corps : un court message générique (« Nous avons bien reçu votre demande d'accès à
        l'information... »)
      - Cette action va **échouer** dans cet environnement (pas de boîte aux lettres) — c'est
        attendu.
   2. Sur l'étape suivante (celle du point 3), ouvre **Paramètres** (icône ⚙ en haut à droite du
      bloc d'action) > **Configurer l'exécution après** > coche les 4 cases (**est réussie, a
      échoué, est ignorée, a expiré**). Ça permet au flux de continuer même si le courriel échoue.
   3. Ajoute **Microsoft Dataverse** > **Ajouter une ligne**.
      - Table : Activité
      - Demande (`gk_DemandeId`) : contenu dynamique **ID de ligne d'origine du déclencheur**
      - Date de l'activité : `utcNow()` (onglet Expression)
      - Action : *Commentaire ajouté*
      - Commentaire : `Accusé de réception (tentative de courriel envoyée - voir l'historique du flux pour le résultat).`
6. **Branche SI NON** :
   1. **Microsoft Dataverse** > **Ajouter une ligne** (Activité), mêmes champs que ci-dessus sauf :
      - Commentaire : `Envoi de courriel désactivé (variable d'environnement gk_EnvoiCourrielActif = false).`
7. Enregistre, puis **Activer** le flux.
8. Pour tester : crée une nouvelle demande dans l'app (`/nouvelle`) et regarde l'historique
   d'exécution du flux (bouton **...** > **Historique des exécutions**) — l'étape courriel doit
   afficher un échec (icône rouge), l'étape suivante doit quand même s'exécuter (grâce à l'étape 5.2
   ou parce que tu es dans la branche NON), et une nouvelle entrée doit apparaître dans le journal
   d'activité de la demande.

---

## Flux 2 — Rappel quotidien des échéances

1. **Nouveau flux cloud automatisé** dans la solution : `Rappel quotidien des échéances`.
2. Déclencheur : **Planification** > **Récurrence**.
   - Intervalle : 1, Fréquence : Jour, Heure de début : à ton choix (ex. 8h00).
3. **Microsoft Dataverse** > **Répertorier des lignes**.
   - Table : Demande AIPRP
   - **Filtrer les lignes** : clique l'icône *fx* (expression) à droite du champ et colle :
     ```
     concat('statecode eq 0 and gk_statut ne 100000013 and gk_statut ne 100000014 and gk_dateecheance le ', formatDateTime(addDays(utcNow(), 5), 'yyyy-MM-dd'))
     ```
     (ça donne : demandes actives, ni Complétées ni Fermées, dont l'échéance est dans 5 jours ou
     moins — retard inclus, puisque « le » veut dire ≤.)
4. Ajoute **Contrôle** > **Appliquer à chacun**, sur la sortie **valeur** de l'étape 3.
5. À l'intérieur de la boucle, ajoute une **Condition** (« Agent assigné ? ») :
   - Gauche : contenu dynamique correspondant au **Agent assigné** (champ lookup) — si le champ
     dynamique direct n'apparaît pas, utilise l'expression `empty(items('Appliquer_a_chacun')?['_gk_agentassigneid_value'])`
   - Est égal à : `false` (si tu utilises `empty(...)`) — sinon choisis l'opérateur qui correspond à
     « n'est pas vide ».
6. **Branche SI OUI (agent assigné)** :
   1. **Microsoft Dataverse** > **Obtenir une ligne par ID**.
      - Table : Utilisateurs (systemusers)
      - ID de ligne : contenu dynamique de l'agent assigné (`_gk_agentassigneid_value`)
   2. **Notifications** (ou **Power Apps Notification V2**) > **Envoyer une notification** /
      **Envoyer une notification à l'utilisateur spécifié**.
      - Destinataire : essaie d'abord le champ **Courriel principal** (`internalemailaddress`) de
        l'étape 6.1 ; si le champ « Destinataire » refuse ce format, utilise plutôt
        **azureactivedirectoryobjectid** du même utilisateur (regarde l'indice/placeholder du champ
        dans Studio, il précise le format attendu).
      - Titre : `Échéance à surveiller`
      - Message : combine dynamiquement le numéro de la demande et la date d'échéance, par exemple
        `concat('Demande ', items('Appliquer_a_chacun')?['gk_name'], ' - echeance le ', items('Appliquer_a_chacun')?['gk_dateecheance'])`
7. Enregistre, **Activer**. Pour tester sans attendre le lendemain : ouvre le flux et utilise
   **Tester** > **Manuellement** en haut à droite.

## Comment recevoir les notifications pour tester (application mobile Power Automate)

Pas besoin de mobile pour tester — les deux fonctionnent :

- **Le plus simple, sur le web** : va sur [make.powerautomate.com](https://make.powerautomate.com),
  clique l'icône 🔔 (cloche) en haut à droite. Les notifications envoyées par le flux y apparaissent
  directement, aucune installation requise.
- **Sur mobile** (si tu veux vraiment tester le push) : installe l'app **Power Automate** (iOS ou
  Android), connecte-toi avec le même compte Power Platform que celui utilisé pour construire les
  flux, autorise les notifications quand l'app le demande. Les notifications du connecteur
  **Notifications** / **Power Apps Notification** arrivent comme des notifications push normales.

---

## Flux 3 — Approbation de prorogation

Voir [ADR 0003](adr/0003-approbation-prorogation-par-flux.md) : depuis la Phase 3, ce flux est
**l'unique** mécanisme qui approuve une prorogation — l'app ne fait plus que la demande.

1. **Nouveau flux cloud automatisé** dans la solution : `Approbation de prorogation`.
2. Déclencheur : **Microsoft Dataverse** > **Lorsqu'une ligne est ajoutée, modifiée ou supprimée**.
   - **Modifier les lignes de** : *Ajoutée ou modifiée*
   - Table : Demande AIPRP, Portée : Organisation
   - **Filtrer les colonnes** : `gk_statut` (limite les déclenchements aux changements de statut
     seulement)
   - **Conditions de déclenchement avancées** (icône ⚙ > Paramètres > Conditions de déclenchement) :
     `@equals(triggerOutputs()?['body/gk_statut'], 100000012)`
     (ne déclenche que lorsque le statut devient *Prorogée* — évite les boucles et le bruit)
3. **Standard approvals** (« Approbations ») > **Démarrer et attendre une approbation**.
   - Type d'approbation : *Approbation/Rejet - Le premier qui répond l'emporte*
   - Titre : `Prorogation - ` + contenu dynamique **Numéro**
   - Attribuer à : ton propre compte (celui avec lequel tu es connectée) — il n'y a pas encore de
     compte Gestionnaire distinct (Phase 4)
   - Détails : inclus le motif (`gk_motifprorogation`) et la nouvelle échéance proposée
     (`gk_nouvelleecheanceprorogation`) en contenu dynamique
4. **Condition** (« Approuvée ? ») :
   - Gauche : contenu dynamique **Résultat** de l'étape 3
   - Est égal à : `Approve`
5. **Branche SI OUI** :
   1. **Microsoft Dataverse** > **Mettre à jour une ligne** (Demande AIPRP, ID = ligne du
      déclencheur) : Statut = *En traitement*, Date d'échéance = contenu dynamique **Nouvelle
      échéance (prorogation)** du déclencheur.
   2. **Microsoft Dataverse** > **Ajouter une ligne** (Activité) : Action = *Prorogation approuvée*,
      Commentaire = `Prorogation approuvée. Nouvelle echeance appliquee.`
6. **Branche SI NON (rejetée)** :
   1. **Microsoft Dataverse** > **Mettre à jour une ligne** (Demande AIPRP) : Statut = *En
      traitement* (retour au traitement normal, sans appliquer la nouvelle échéance).
   2. **Microsoft Dataverse** > **Ajouter une ligne** (Activité) : Action = *Changement de statut*,
      Commentaire = `Prorogation rejetee.`
7. Enregistre, **Activer**.

## Où répondre à une approbation (sans Outlook)

Va sur [make.powerautomate.com](https://make.powerautomate.com) > **Approbations** dans le menu de
gauche (ou l'icône 🔔 si l'approbation y apparaît aussi). Tu verras la carte « Prorogation - A-2026-... »
avec les détails (motif, nouvelle échéance) et deux boutons **Approuver** / **Rejeter**, directement
dans le navigateur — aucune boîte de courriel n'est nécessaire. C'est le même portail que celui où tu
construis les flux.

**Pour tester** : demande une prorogation dans l'app (`/detail/<id>`), puis va dans
**Approbations** — la carte doit apparaître en quelques secondes. Approuve-la, puis retourne dans
l'app : le statut doit être passé à *En traitement* avec la nouvelle échéance appliquée, et le
journal doit contenir l'entrée « Prorogation approuvée ».
