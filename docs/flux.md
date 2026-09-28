# Flux Power Automate

⚠️ **Ces flux doivent être construits dans le portail Power Automate** (make.powerautomate.com,
même environnement Dataverse que l'app). Je ne peux pas cliquer dans le portail — ce document donne
les instructions précises, étape par étape, à suivre toi-même. Les 3 flux doivent faire partie de la
solution **Suivi AIPRP** (pas de « My flows » / solution par défaut).

## Limite de licence — pas d'Exchange/Outlook

Le tenant de développement n'a pas de boîte aux lettres. Deux cas de figure très différents :

- **Notifier un agent ou une gestionnaire** (utilisateur·rice Power Platform interne) : possible
  sans Exchange — voir la section « Pourquoi pas le connecteur Notifications » plus bas.
- **Envoyer un accusé de réception au demandeur externe** (courriel fictif comme
  `amara.cloutier@exemple-fictif.ca`) : **impossible avec ou sans licence**, puisque ce n'est pas un
  compte Power Platform — aucun connecteur de notification interne ne peut l'atteindre. Le flux 1
  tente quand même un vrai courriel (Office 365 Outlook), avec gestion d'erreur, pour rester réaliste
  et démontrable.

## Vérifications faites avant d'écrire ces instructions

- **`gk_dateecheance` n'est pas une colonne formule.** Confirmé directement sur le schéma en
  production (`SourceType: 0`, `IsValidForUpdate: true`) : c'est une colonne `DateTime` normale, le
  flux 3 peut la modifier sans contournement. Voir [modele-donnees.md](modele-donnees.md).
- **Le connecteur Notifications (`shared_flowpush`) est entièrement déprécié.** Ses deux actions
  (« M'envoyer une notification mobile » et « M'envoyer une notification par courriel ») ne
  fonctionnent plus (confirmé dans la référence officielle du connecteur). Le flux 2 utilise donc
  **Standard approvals** à la place — voir plus bas.
- **Le connecteur Power Apps Notification** (`shared_powerappsnotificationv2`) fonctionne encore et
  peut cibler un utilisateur précis, mais il est conçu pour les apps canvas/pilotées par modèle
  (notification affichée dans Power Apps Mobile) — son comportement avec une code app n'est pas
  documenté, et chaque destinataire doit avoir déjà ouvert l'app dans Power Apps Mobile une fois. Pas
  assez fiable pour cette démo ; non retenu.

## Sur les expressions et les noms d'étapes

Power Automate nomme automatiquement chaque étape selon le libellé français de l'action (ex.
« Appliquer à chacun »), donc une expression comme `items('Appliquer_a_chacun')` **peut ne pas
correspondre exactement** à ce que ton portail génère (espaces, accents, numérotation si tu renommes
une étape). Deux façons fiables de faire la même chose :

1. **Utilise le sélecteur de contenu dynamique** (le panneau qui s'ouvre automatiquement quand tu
   cliques dans un champ) : cherche le champ par son nom (ex. « Numéro ») et clique dessus. Power
   Automate insère la bonne référence pour toi, peu importe le nom réel de l'étape. **Préfère
   toujours cette méthode** dans les instructions ci-dessous.
2. Si une expression est vraiment nécessaire (ex. `empty(...)`), clique dans le champ, ouvre l'onglet
   **Expression**, tape le début (`items(`) et laisse l'auto-complétion te proposer le nom réel de ta
   boucle — ne recopie jamais un nom d'étape à l'aveugle depuis ce document.

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
      - À : contenu dynamique **Courriel du demandeur**
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
      - Demande : contenu dynamique **ID de ligne d'origine du déclencheur**
      - Date de l'activité : `utcNow()` (onglet Expression)
      - Action : *Commentaire ajouté*
      - Commentaire : `Accusé de réception (tentative de courriel envoyée - voir l'historique du flux pour le résultat).`
6. **Branche SI NON** :
   1. **Microsoft Dataverse** > **Ajouter une ligne** (Activité), mêmes champs que ci-dessus sauf :
      - Commentaire : `Envoi de courriel désactivé (variable d'environnement gk_EnvoiCourrielActif = false).`
7. Enregistre, puis **Activer** le flux.
8. Pour tester : crée une nouvelle demande dans l'app (`/nouvelle`) et regarde l'historique
   d'exécution du flux (bouton **...** > **Historique des exécutions**) — l'étape courriel doit
   afficher un échec (icône rouge), l'étape suivante doit quand même s'exécuter, et une nouvelle
   entrée doit apparaître dans le journal d'activité de la demande.

---

## Flux 2 — Rappel quotidien des échéances

1. **Solutions** > **Suivi AIPRP** > **Nouveau** > **Automatisation** > **Flux cloud** >
   **Planifié** (⚠️ pas *Automatisé* — un flux planifié se déclenche par horaire, pas par
   événement).
2. Dans la boîte de dialogue de création :
   - Nom du flux : `Rappel quotidien des échéances`
   - **Démarrant** : aujourd'hui, à l'heure de ton choix (ex. 8h00)
   - **Se répétant tous les** : 1 **Jour**
   - Clique **Créer** — Studio s'ouvre avec le déclencheur **Récurrence** déjà en place.
3. **Microsoft Dataverse** > **Répertorier des lignes**.
   - Table : Demande AIPRP
   - **Filtrer les lignes** : clique l'icône *fx* (expression) à droite du champ et colle :
     ```
     concat('statecode eq 0 and gk_statut ne 100000013 and gk_statut ne 100000014 and gk_dateecheance le ', formatDateTime(addDays(utcNow(), 5), 'yyyy-MM-dd'))
     ```
     (demandes actives, ni Complétées ni Fermées, dont l'échéance est dans 5 jours ou moins — retard
     inclus, puisque « le » veut dire ≤. Cette expression ne dépend d'aucun nom d'étape, elle est
     sûre à copier telle quelle.)
4. Ajoute **Contrôle** > **Appliquer à chacun**, et clique dans son champ pour choisir, via le
   **contenu dynamique**, la **valeur** renvoyée par l'étape 3 (ne tape pas le nom de l'étape,
   sélectionne-le dans la liste).
5. À l'intérieur de la boucle, ajoute une **Condition** (« Agent assigné ? ») :
   - Clique dans le champ de gauche : le sélecteur de contenu dynamique propose maintenant les
     champs de la demande courante (puisque tu es à l'intérieur du « Appliquer à chacun »). Cherche
     le champ correspondant à **Agent assigné** (ou son identifiant) et sélectionne-le.
   - Si aucun champ dynamique direct n'apparaît pour la valeur de la référence, utilise l'onglet
     **Expression**, tape `empty(items(` et laisse l'auto-complétion terminer avec le nom réel de ta
     boucle, puis ajoute `)?['_gk_agentassigneid_value'])`.
   - Opérateur : **est égal à**, valeur : `false` (si tu utilises `empty(...)`, false = non vide).
6. **Branche SI OUI (agent assigné)** — voir « Pourquoi pas le connecteur Notifications » ci-dessous
   pour le choix du connecteur :
   1. **Standard approvals** > **Créer une approbation** (*sans* attendre — contrairement au flux 3).
      - Type d'approbation : *Approbation/Rejet - Le premier qui répond l'emporte*
      - Titre : `Rappel echeance -` puis contenu dynamique **Numéro** (choisi via le sélecteur, pas
        tapé)
      - Attribuer à : ton propre compte (celui avec lequel tu es connectée) — il n'y a qu'une seule
        agente réelle dans cet environnement, voir la limite documentée plus bas
      - Détails : ajoute le contenu dynamique **Date d'échéance** de la demande courante
7. Enregistre, **Activer**. Pour tester sans attendre le lendemain : ouvre le flux et utilise
   **Tester** > **Manuellement** en haut à droite.

### Pourquoi pas le connecteur Notifications

Le connecteur **Notifications** (`shared_flowpush`, celui avec l'action « M'envoyer une notification
mobile ») est **déprécié** — confirmé dans sa documentation officielle : *"Mobile notifications are
deprecated and no longer delivered."* Il ne fonctionnerait pas, même pour une démo. Le connecteur
**Power Apps Notification** existe encore mais cible spécifiquement les apps canvas/pilotées par
modèle affichées dans Power Apps Mobile, avec un prérequis (chaque destinataire doit avoir ouvert
l'app mobile au moins une fois) — pas adapté à une code app ni fiable à tester rapidement.

**Solution retenue** : réutiliser le connecteur **Standard approvals**, déjà nécessaire pour le
flux 3, avec son action « Créer une approbation » **sans attendre la réponse** — ça crée simplement
une carte d'information dans le même centre d'approbations que tu vérifieras de toute façon.
**Limite à documenter** : ce n'est pas une vraie notification push, seulement une carte visible en
allant consulter le portail (voir « Comment vérifier les rappels » ci-dessous) — acceptable pour une
démonstration, mais à remplacer par un vrai connecteur de notification (Teams, par exemple) si ce
projet évoluait vers un usage réel avec plusieurs agent·es.

### Comment vérifier les rappels (flux 2)

Va sur [make.powerautomate.com](https://make.powerautomate.com) > **Approbations** dans le menu de
gauche. Les cartes créées par le flux 2 y apparaissent, avec le numéro de la demande et l'échéance en
détail — pas besoin d'application mobile ni de courriel.

---

## Flux 3 — Approbation de prorogation

Voir [ADR 0003](adr/0003-approbation-prorogation-par-flux.md) : depuis la Phase 3, ce flux est
**l'unique** mécanisme qui approuve une prorogation — l'app ne fait plus que la demande.

**Cycle de statut** (corrigé après relecture — *Prorogée* ne veut plus dire « demandée ») :

```
En traitement → (agent·e clique "Demander une prorogation") → Prorogation demandée
  → (flux + approbation) →
    ├─ approuvée → Prorogée (nouvelle echeance appliquee)
    └─ rejetee   → En traitement (echeance inchangee)
```

1. **Solutions** > **Suivi AIPRP** > **Nouveau** > **Automatisation** > **Flux cloud** >
   **Automatisé** : `Approbation de prorogation`.
2. Déclencheur : **Microsoft Dataverse** > **Lorsqu'une ligne est ajoutée, modifiée ou supprimée**.
   - **Modifier les lignes de** : *Ajoutée ou modifiée*
   - Table : Demande AIPRP, Portée : Organisation
   - **Filtrer les colonnes** : `gk_statut` (limite les déclenchements aux changements de statut
     seulement)
   - **Conditions de déclenchement avancées** (icône ⚙ > Paramètres > Conditions de déclenchement) :
     `@equals(triggerOutputs()?['body/gk_statut'], 100000015)`
     (ne déclenche que lorsque le statut devient *Prorogation demandée* — **100000015**, pas
     100000012. Évite les boucles et le bruit : le flux se remet à jour le statut vers *Prorogée*
     ou *En traitement*, ce qui redéclenchera le trigger Dataverse, mais la condition ci-dessus sera
     alors fausse et le flux ne fera rien.)
3. **Standard approvals** > **Démarrer et attendre une approbation**.
   - Type d'approbation : *Approbation/Rejet - Le premier qui répond l'emporte*
   - Titre : `Prorogation -` puis contenu dynamique **Numéro** (sélectionné, pas tapé)
   - Attribuer à : ton propre compte (celui avec lequel tu es connectée) — il n'y a pas encore de
     compte Gestionnaire distinct (Phase 4)
   - Détails : ajoute les contenus dynamiques **Motif de la prorogation** et **Nouvelle échéance
     (prorogation)** de la demande déclenchante
4. **Condition** (« Approuvée ? ») :
   - Gauche : contenu dynamique **Résultat** de l'étape précédente (sélectionné dans le contenu
     dynamique, pas tapé)
   - Est égal à : `Approve`
5. **Branche SI OUI** :
   1. **Microsoft Dataverse** > **Mettre à jour une ligne** (Demande AIPRP, ID = ligne du
      déclencheur) : Statut = *Prorogée*, Date d'échéance = contenu dynamique **Nouvelle échéance
      (prorogation)** du déclencheur.
   2. **Microsoft Dataverse** > **Ajouter une ligne** (Activité) : Action = *Prorogation approuvée*,
      Commentaire = `Prorogation approuvee. Nouvelle echeance appliquee.`
6. **Branche SI NON (rejetée)** :
   1. **Microsoft Dataverse** > **Mettre à jour une ligne** (Demande AIPRP) : Statut = *En
      traitement* (retour au traitement normal, échéance inchangée).
   2. **Microsoft Dataverse** > **Ajouter une ligne** (Activité) : Action = *Changement de statut*,
      Commentaire = `Prorogation rejetee.`
7. Enregistre, **Activer**.

## Où répondre à une approbation (sans Outlook)

Va sur [make.powerautomate.com](https://make.powerautomate.com) > **Approbations** dans le menu de
gauche. Tu verras la carte « Prorogation - A-2026-... » avec les détails (motif, nouvelle échéance)
et deux boutons **Approuver** / **Rejeter**, directement dans le navigateur — aucune boîte de
courriel n'est nécessaire.

**Pour tester** : demande une prorogation dans l'app (`/detail/<id>`) — le statut doit passer à
*Prorogation demandée* — puis va dans **Approbations** ; la carte doit apparaître en quelques
secondes. Approuve-la, puis retourne dans l'app : le statut doit être passé à *Prorogée* avec la
nouvelle échéance appliquée, et le journal doit contenir l'entrée « Prorogation approuvée ».
