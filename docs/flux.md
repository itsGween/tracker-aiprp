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

## Pièges rencontrés en testant

**Les variables d'environnement n'apparaissent pas toujours du premier coup dans le contenu
dynamique générique.** Si tu cherches la variable dans le panneau de contenu dynamique d'une étape
et qu'elle n'apparaît pas, **ne tape pas une expression à la main** en devinant la syntaxe (ex.
`parameters('...')`) — une expression mal formée référence un paramètre qui n'existe pas dans la
définition du flux et échoue à l'exécution avec une erreur du genre *"The workflow parameter ...
is not found"*. Ferme et rouvre l'étape, ou le flux au complet, et recherche à nouveau la variable
dans le contenu dynamique — elle finit par apparaître. Si elle n'apparaît vraiment jamais, la
fonction d'expression `environmentVariables('schemaname')` reste une solution de repli valide, mais
à taper dans l'onglet **Expression**, pas à deviner sous forme de `parameters(...)`.

**Deux couches différentes pour une variable Booléen — ne pas les confondre.** Le champ « Valeur
par défaut » d'une variable d'environnement Booléen, dans Dataverse et dans le portail Power Apps,
**stocke** la valeur sous forme de texte `yes`/`no` (c'est ce que `scripts/New-EnvironmentVariable.ps1`
écrit — corrigé après avoir constaté que `"false"`/`"true"` sont acceptés sans erreur par l'API à la
création mais ne s'affichent pas correctement ensuite dans le portail). **Mais** une fois cette
variable lue dans un flux via le contenu dynamique, Power Automate la **type comme un vrai booléen**
de son langage d'expression, dont les littéraux sont `true`/`false` (pas `yes`/`no`) — c'est donc
bien `true`/`false` qu'on utilise dans la **comparaison** de l'étape Condition (voir Flux 1, étape 4
ci-dessous). En résumé : `no`/`yes` pour la valeur par défaut de la variable ; `true`/`false` pour la
comparer dans un flux.

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
**no** dans cet environnement (format de stockage — voir « Pièges rencontrés en testant »). Le
flux 1 la consulte pour décider d'essayer ou non l'envoi de courriel, sans qu'on ait à modifier le
flux si un jour cet environnement (ou un autre) obtient une vraie boîte aux lettres — il suffira de
changer la valeur de la variable à `yes` dans le portail. ⚠️ Après avoir changé la valeur, **désactive
puis réactive le flux** pour qu'il relise la nouvelle valeur (constaté en test : un flux déjà activé
ne recharge pas automatiquement une variable d'environnement modifiée après coup).

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
   - Clique dans le champ de gauche > **Contenu dynamique** > cherche la variable
     **Envoi de courriel actif**, sélectionne-la (ne tape pas d'expression à la main — voir « Pièges
     rencontrés en testant » ci-dessous si elle n'apparaît pas du premier coup).
   - Opérateur : **est égal à**
   - Valeur de droite : `true` (comparaison booléenne du flux — voir « Pièges rencontrés en
     testant » pour la distinction avec la valeur `no`/`yes` stockée sur la variable elle-même)
5. **Branche SI OUI** :
   1. Ajoute **Office 365 Outlook** > **Envoyer un courriel (V2)** — ou le connecteur **Mail**
      (`Send an email from your own email address`) si Office 365 Outlook n'est pas disponible ou
      échoue dans ta connexion. Le connecteur **Mail** ne nécessite pas de boîte Exchange/Outlook
      (il envoie depuis une adresse générée par Microsoft), ce qui en fait une meilleure option pour
      cet environnement de développement.
      - À : contenu dynamique **Courriel du demandeur**
      - Objet : `Accusé de réception - Demande` (contenu dynamique **Numéro** à la suite)
      - Corps : un court message générique (« Nous avons bien reçu votre demande d'accès à
        l'information... »)
      - Avec Office 365 Outlook, cette action **échoue** dans cet environnement (pas de boîte aux
        lettres) — c'est attendu et géré par l'étape 5.2 ci-dessous. Avec le connecteur Mail, elle
        réussit réellement.
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
      - Commentaire : `Envoi de courriel désactivé (variable d'environnement gk_EnvoiCourrielActif = no).`
7. Enregistre, puis **Activer** le flux.
8. Pour tester : crée une nouvelle demande dans l'app (`/nouvelle`) et regarde l'historique
   d'exécution du flux (bouton **...** > **Historique des exécutions**) — l'étape courriel doit
   afficher un échec (icône rouge), l'étape suivante doit quand même s'exécuter, et une nouvelle
   entrée doit apparaître dans le journal d'activité de la demande.

### Résultats des tests

Les deux branches ont été testées avec des demandes fictives créées par script, en changeant la
valeur de `gk_EnvoiCourrielActif` entre les deux (avec désactivation/réactivation du flux entre les
deux changements — voir « Un flux activé ne relit pas une variable d'environnement modifiée »).

| Test | Variable | Demande de test | Résultat |
|---|---|---|---|
| Branche Si Non | `no` | « TEST FLUX 1 - Sans courriel 3 » | ✅ Activité **ACT-01038** créée en quelques secondes : « Envoi de courriel désactivé (variable d'environnement gk_EnvoiCourrielActif = false). » |
| Branche Si Oui | `yes` | « TEST FLUX 1 - Avec courriel » | ✅ Activité **ACT-01039** créée en quelques secondes : « Accusé de réception envoyé par courriel au demandeur (voir l'historique du flux pour le résultat). » |

Les deux branches du flux 1 sont confirmées fonctionnelles. La variable a été remise à `no` après le
test (aucune boîte aux lettres réelle dans cet environnement de développement).

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
5. À l'intérieur de la boucle, ajoute une **Condition** (nomme-la « Agent assigné », **sans point
   d'interrogation** — voir « Pièges rencontrés » ci-dessous) :
   - Clique dans le champ de gauche : le sélecteur de contenu dynamique propose maintenant les
     champs de la demande courante (puisque tu es à l'intérieur du « Appliquer à chacun »). Cherche
     le champ correspondant à **Agent assigné** (ou son identifiant) et sélectionne-le.
   - Opérateur : **n'est pas égal à**
   - Valeur de droite : ouvre l'onglet **Expression** et tape `null` (le littéral d'expression, pas
     le texte `"null"` entre guillemets — voir « Pièges rencontrés » ci-dessous).
6. **Branche SI OUI (agent assigné)** — voir « Pourquoi pas le connecteur Notifications » ci-dessous
   pour le choix du connecteur :
   1. **Standard approvals** > **Créer une approbation** (*sans* attendre — contrairement au flux 3).
      - Type d'approbation : *Approbation/Rejet - Le premier qui répond l'emporte*
      - Titre : `Rappel echeance -` puis contenu dynamique **Numéro** (choisi via le sélecteur, pas
        tapé)
      - Attribuer à : ton propre compte (celui avec lequel tu es connectée) — il n'y a qu'une seule
        agente réelle dans cet environnement, voir la limite documentée plus bas
      - Détails : ajoute le contenu dynamique **Date d'échéance** de la demande courante
      - Après avoir rempli les champs, **enregistre le flux avant de fermer l'étape** — voir
        « Pièges rencontrés » ci-dessous si l'exécution échoue avec *AssignedToMissing*.
7. Enregistre, **Activer**. Pour tester sans attendre le lendemain : ouvre le flux et utilise
   **Tester** > **Manuellement** en haut à droite.

### Pièges rencontrés (flux 2)

- **Un nom d'étape ne peut pas contenir `?`.** Nommer la condition « Agent assigné ? » échoue à
  l'enregistrement avec l'erreur *InvalidWorkflowRunActionName*. Les noms d'étapes Power Automate
  n'acceptent pas la ponctuation comme `?` — s'en tenir à lettres, chiffres, espaces et tirets.
- **La condition sur un champ de référence (lookup) vide compare avec l'expression `null`, pas le
  texte `"null"`.** Taper `"null"` (chaîne de caractères) dans l'onglet Expression ne correspondra
  jamais à une valeur de référence réellement vide — le champ n'est jamais littéralement égal au
  texte "null". Il faut taper `null` sans guillemets : c'est alors le littéral du langage
  d'expression de Power Automate (l'absence de valeur), pas une chaîne.
- **L'ancien concepteur (design classique) n'enregistre pas toujours les champs d'une action
  Standard Approvals.** L'exécution du flux échouait avec *InvalidApprovalCreateRequestAssignedToMissing*
  alors que le champ « Attribuer à » semblait rempli dans l'éditeur. Solution : supprimer l'action
  « Créer une approbation » et la recréer (plutôt que de simplement rouvrir/re-remplir les mêmes
  champs), puis vérifier avec le bouton **Lire le code** (icône `</>` en haut de l'étape, ou dans le
  menu **...**) que la propriété `assignedTo` apparaît bien dans le JSON de l'action avant
  d'enregistrer.

### Résultats des tests (flux 2)

Exécuté manuellement (**Tester** > **Manuellement**) sur les données de démo existantes : 3 demandes
actives correspondaient au filtre (agent assigné + échéance ≤ 5 jours, retard inclus). ✅ Les 3
cartes « Rappel echeance - A-2026-... » sont apparues dans le centre **Approbations**.

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
