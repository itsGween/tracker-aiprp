# Progression du projet

Document de suivi interne (équipe Gween + assistant), pas destiné à la doc publique finale — mais
gardé dans le dépôt comme trace du cheminement réel, utile pour l'entrevue et pour reprendre le
travail après une pause. Mis à jour au fil des phases.

## Programme de finalisation (depuis le 31 octobre 2026)

Ce programme en 8 phases fait suite à l'audit du 6 octobre. Sa numérotation est distincte de celle
de l'historique, plus bas dans ce document.

### État des phases

- [x] **Phase 1** — Stabiliser l'application : terminée, fusionnée dans `main`, publiée et vérifiée
  à l'écran. Deux contrôles mineurs n'ont pas été faits : l'encadré jaune et le lien d'évitement
  dans l'application publiée.
- [x] **Phase 2** — Flux 3 (approbation des prorogations), améliorations des flux 1 et 2 : terminée
  le 1er novembre, testée et fusionnée dans `main`.
- [ ] **Phase 3** — Sécurité (rôles Agent AIPRP et Gestionnaire AIPRP).
- [ ] **Phase 4** — ALM (solution dépaquetée, déploiement, GitHub Actions). Le fichier de paramètres
  de déploiement doit fournir les valeurs de `gk_ApprobateurProrogation` et `gk_DestinataireRappels`.
- [ ] **Phase 5** — Accessibilité (axe-core étendu, tests manuels).
- [ ] **Phase 6** — Documentation professionnelle, MkDocs, v1.0.0, typographie française de
  l'interface (espace avant les deux-points : « Statut : », à vérifier dans tous les textes FR).
- [ ] **Phase 7** — Ménage de l'environnement, accents des données de démo et de leur script,
  script de rafraîchissement des dates par rapport à la date du jour, qui devra aussi remettre
  `gk_daterappel` à vide. Supprimer la demande de test A-2026-01022 (« TEST FLUX 1 ») et les anciens
  cartons de rappel en double.
- [ ] **Phase 8** — Ajout au portfolio gweenkangah.pro.

### Échéance de l'environnement : 15 décembre 2026

L'environnement est de type **Développeur, non géré** : Microsoft le suspend le **15 décembre 2026**
et le supprime le 15 janvier 2027. Tout ce qui dépend de lui (captures des portails, vidéo, tests
des rôles, test de redéploiement) doit être fait avant le 15 décembre. Séquence d'urgence acceptée
par Gween le 1er novembre, avant la phase 3 :

- [x] Étape 0 — Vérification dans le centre d'administration (Développeur, Géré : Non).
- [x] Étape 1 — Sauvegarde : solution dépaquetée, données de démo, paramètres de déploiement
  (`e42ec6c`). Revérifiée le 2 novembre : nouvel export identique (53 fichiers sur 53, 15 demandes,
  39 activités).
- [~] Étape 2 — Captures et vidéo : 01 à 07 et 09 à 16 faites le 2 novembre, GIF de secours
  enregistré. Restent 08, 17 à 19 (phase 3), la vidéo commentée et les captures à refaire.
- [x] Étape 3 — Mode démo sans Dataverse évalué le 2 novembre : environ 2 jours, services générés
  remplacés par des services démo, données de `data/demo/` décalées sur la date du jour. Accepté,
  codé du 11 au 19 décembre.
- [ ] Étape 4 — `docs/installation.md`, test réel du redéploiement, options pour garder un
  environnement (géré, essai, bac à sable), coûts et licences.
- [x] Étape 5 — Calendrier fixé par Gween le 2 novembre (liste ci-dessous). La phase 3 suit
  l'étape 4.

### Reste à faire avant le 15 décembre 2026 (par priorité)

Liste établie le 2 novembre 2026. Les dates à partir de la phase 3 sont celles demandées par Gween
le 2 novembre, avec une marge de sécurité avant le 15 décembre ; à reprendre telles quelles dans le
calendrier de l'étape 5.

- [x] **2 nov.** — Étape 3 : évaluation du mode démo présentée et acceptée (voir les décisions).
- [ ] **Maintenant** — Étape A : vérification des identifiants, fusion de
  `phase-4/alm-sauvegarde` dans `main`, push, contrôle du dépôt public.
- [ ] **Maintenant** — Étape B : première version du portfolio (carte du projet, étude de cas
  bilingue « en cours »), plan présenté avant de coder ; README du profil GitHub.
- [ ] **13 nov.** — Étape 4 : écrire `docs/installation.md`, puis tester réellement le
  redéploiement de la solution et des données dans un autre environnement (`Import-DonneesDemo.ps1
  -Importer` n'a encore jamais tourné pour de vrai). Ce test doit être fait tant que l'environnement
  source existe, pour pouvoir comparer.
- [x] **2 nov.** — Étape 5 : calendrier fixé par Gween (dates de cette liste).
- [ ] **1er déc.** — Phase 3 (plug-in C#, sécurité de colonne sur `gk_dateecheance`, rôles,
  compte `agent.test`, ADR 0005), avec les captures 08 et 17 pendant les tests, 18 et 19 à la fin
  (méthode dans `docs/captures.md`).
- [ ] **3 déc.** — Ménage des données nécessaire aux captures, avec l'accord de Gween pour
  chaque suppression : demande de test A-2026-01022, cartons de rappel en double, courriels en
  `example.com`, dates rafraîchies. A-2026-01021 est supprimée à la fin des tests de la phase 3,
  avant de refaire les captures (accord de Gween du 2 nov.).
- [ ] **5 déc.** — Refaire les captures 01, 02, 03, 03b, 06 et 14 (somme des tuiles = 15).
- [ ] **8 déc.** — Vidéo commentée (scénario final dans `docs/captures.md`), téléversée sur YouTube
  en « non répertoriée », original dans OneDrive.
- [ ] **10 déc.** — Dernier export de la solution et des données, comparaison avec le dépôt, copie
  des fichiers hors Git dans OneDrive, et vérification que le redéploiement fonctionne.
- [ ] **Du 11 au 19 déc.** — Mode démo autonome (ADR 0006), publié sur Vercel.
- [ ] **Sans échéance stricte** — Phases 4 à 8. Les parties qui
  utilisent un environnement (déploiement de la phase 4) dépendront de l'option retenue à l'étape 4.

Pièges notés pendant les étapes 1 et 2 :

- Dépaqueté en non géré seul, l'export montre une dépendance manquante `systemuser` (solution
  `msdyn_PowerAdminSettingsEmail`) que le dépaquetage `Both` ne montre pas. À surveiller lors du test
  de redéploiement de l'étape 4.
- Dans le nouveau concepteur, déplier une branche active le bouton Enregistrer. Toujours sortir par
  « Précédent » ; la date de modification du flux 3 est restée au 31 oct., 15 h 20.
- Les captures Playwright locales n'ont pas de données (pas d'hôte Power Apps) : les écrans remplis
  se capturent dans l'application publiée.

### Fichiers hors de Git, à garder dans OneDrive

Copiés par Gween dans un dossier privé de son OneDrive le 2 novembre.

| Fichier | Contenu |
|---|---|
| `out/solution/SuiviAIPRP.zip` et `SuiviAIPRP_managed.zip` | Exports de la solution du 2 nov. (identiques à un nouvel export du même jour) |
| `deploy/settings.dev.json` | Paramètres de déploiement avec les valeurs actuelles des variables (comptes réels) |
| `scripts/.env` | URL de l'organisation, locataire et ID de l'environnement |
| `app/power.config.json` | ID de l'application et de l'environnement de la code app |
| `app/.power/` | Schémas générés, nécessaires au build (voir le piège de la phase 1) |
| `docs/audit.md` | Feuille de route de la finalisation, volontairement non commitée |
| `demo-suivi-aiprp-2026-11-02.gif` (dossier Téléchargements) | Démonstration de secours sans son |

### Routine de fin de phase (depuis le 2 novembre 2026)

À appliquer à la fin de chaque phase ou étape importante, dans cet ordre :

1. **Tests** : lint, build, tests unitaires et Playwright doivent passer.
2. **Sauvegarde** : si la solution ou les données ont changé, réexporter (non gérée et gérée),
   dépaqueter dans `src/solution` et comparer avec la sauvegarde précédente. Indiquer à Gween les
   fichiers hors de Git à recopier dans OneDrive (`Sauvegardes\SuiviAIPRP`).
3. **Captures** des nouveautés (lecture seule, aucune adresse courriel ni identifiant, jamais
   d'enregistrement d'un flux), puis mise à jour de `docs/captures.md`.
4. **Documentation** : README FR et EN, documents concernés, ce fichier.
5. **GitHub** : commits en Conventional Commits, fusion dans `main`, push.
6. **Déploiement** : si le code de l'application a changé, la republier et vérifier qu'elle s'ouvre.
7. **Portfolio** : mettre à jour la page du projet sur gweenkangah.pro (statut, nouveautés,
   captures), build, montrer le diff, push **après l'accord de Gween**, puis vérifier le déploiement
   Vercel en ligne.
8. **Résumé** : ce qui est fait, ce qui reste, 3 points à retenir pour les entrevues.

Règles de travail : une branche par phase, plan au début, résumé et 3 points d'entrevue à la fin,
accord de Gween avant de passer à la phase suivante, aucune suppression sans accord explicite.
Ce fichier est mis à jour à la fin de chaque phase et avant toute compaction.

### Résultats de la phase 1

- Dates : les colonnes « date seule » sont traitées comme des jours du calendrier
  (`app/src/utils/dates.ts`) ; le journal affiche l'heure.
- Auteur : `gk_AuteurId` est renseigné via l'API `WhoAmI` (`app/src/utils/auteur.ts`).
- Traductions : textes en dur remplacés par des clés FR/EN.
- Tests : 18 tests unitaires Vitest (fuseau `America/Toronto`) et 12 tests Playwright verts.
- `app/README.md` réécrit, paquet renommé `suivi-aiprp` (version 0.1.0).

Vérification à l'écran (31 octobre) :

| Étape | Résultat |
|---|---|
| Compteurs du tableau de bord | ✅ 3, 7, 1, 2, 1, 2 (avant correction des données) |
| Encadrés | ✅ « En retard (12) » ; encadré jaune non vérifié |
| Échéance de A-2026-01003 | ✅ 2026-09-25, identique à Dataverse |
| Heures du journal | ✅ Affichées, avec le décalage attendu avant correction |
| Auteur | ✅ `ACT-01043` « Test auteur » porte l'auteur Gween Kangah, confirmé dans Dataverse |
| Bascule en anglais | ✅ Titre, menu et libellés ; lien d'évitement non vérifié |

Correction des données appliquée par `scripts/Repair-DonneesDemo.ps1` et relue dans Dataverse :

| Contrôle | Résultat |
|---|---|
| Demande modifiée | 1 : A-2026-01003 revient à « En traitement » |
| Activité ajoutée | 1 : `ACT-01044` |
| Activités déplacées | 37 : aucune à 00:00 UTC, 37 à 16:00 UTC |
| Suppressions | 0 : 16 demandes et 43 activités (41 + `ACT-01043` + `ACT-01044`) |

### Décisions de Gween

| Date | Sujet | Décision |
|---|---|---|
| 31 oct. | Liste des statuts (phase 2) | Retirer « Prorogation demandée » et « Prorogée ». Le premier n'est posé que par le bouton (avec motif et date), le second que par le flux 3. À documenter dans l'ADR 0003, en précisant que le blocage est côté interface et que les rôles de la phase 3 devront le renforcer côté Dataverse |
| 31 oct. | A-2026-01003 | Remettre à « En traitement » par script, avec une entrée au journal |
| 31 oct. | A-2026-01021 | Garder jusqu'à la phase 7, pour les tests de la phase 2 |
| 31 oct. | Activités de démo | Les déplacer à midi et corriger `New-DemoData.ps1`. Rien d'autre ne change dans les 15 demandes |
| 31 oct. | `.power/` (phase 4) | Versionner s'il ne contient ni identifiant ni secret, sinon régénérer dans le pipeline. Constat : aucun identifiant d'environnement, de locataire ou d'application. Option proposée, à confirmer : versionner seulement `dataSourcesInfo.ts` |
| 31 oct. | Plan de la phase 2 | Plan en 8 points approuvé |
| 31 oct. | Rappels du flux 2 | Un seul rappel par échéance, avec la colonne `gk_daterappel` |
| 31 oct. | Approbateur du flux 3 | Variable d'environnement `gk_ApprobateurProrogation`, pour qu'aucun compte réel n'entre dans le dépôt |
| 31 oct. | Tests de la phase 2 | Uniquement sur A-2026-01021 |
| 31 oct. | Section « Demander une prorogation » | Affichée seulement au statut « En traitement » |
| 31 oct. | Entrées du journal contenant « = false » | Données historiques, ne pas les modifier. Corriger seulement le texte du flux 1 pour les prochaines entrées |
| 31 oct. | Ajouts à la phase 7 | Accents dans les données de démo et dans `New-DemoData.ps1`, script de rafraîchissement des dates |
| 2 nov. | A-2026-01021 | Supprimer à la fin des tests de la phase 3, avant de refaire les captures (remplace « garder jusqu'à la phase 7 ») |
| 2 nov. | Calendrier avant le 15 déc. | Marge de sécurité : phase 3 le 1er déc., ménage le 3, captures refaites le 5, vidéo le 8, dernier export et vérification du redéploiement le 10 |
| 2 nov. | Fichiers hors Git | Copiés dans un dossier privé du OneDrive de Gween |
| 2 nov. | Routine de fin de phase | 8 points, appliquée à chaque phase ou étape terminée (voir plus haut) |
| 2 nov. | Mode démo (étape 3) | Accepté dans son principe, codé du 11 au 19 décembre avec l'ADR 0006, avancé si la phase 3 finit plus tôt. Hébergé sur Vercel, dans un projet séparé du portfolio |
| 2 nov. | Mise en ligne | Priorité changée : avant l'étape 4, fusionner dans `main` (étape A), publier une première version du portfolio (étape B, phase 8 avancée) et ajouter le projet au README du profil GitHub |

### Pièges rencontrés en phase 1

| Piège | Solution |
|---|---|
| `new Date("AAAA-MM-JJ")` lit la date à minuit UTC, soit la veille à Ottawa | Calculer sur la partie `AAAA-MM-JJ`, sans conversion de fuseau |
| `toISOString()` donne la date de demain après 20 h à Ottawa | Construire la date du jour à partir de l'heure locale |
| Ajouter 30 jours en heure locale perd un jour au passage à l'heure avancée (30 mars au lieu du 31) | `ajouterJours` calcule en UTC sur des jours entiers |
| `getContext()` donne l'ID Entra, alors que le lookup attend un `systemuserid` | Appeler `WhoAmI` |
| `pa app add dataverse-api` ajoute aussi une source de données dans `power.config.json` | Normal ; fichier local, non versionné |
| `pac env fetch --xml` attend le XML en texte | Utiliser `--xmlFile`, avec un chemin Windows |
| `pac env fetch` refuse l'attribut `top` | Le retirer de la requête |
| `pa app push --non-interactive` exige l'environnement | Définir `PA_CLI_ENVIRONMENT_ID` à partir de `power.config.json`, sans l'afficher |
| Les activités du script de démo étaient écrites à minuit UTC | Les écrire à midi, heure locale |
| `.power/` est ignoré par Git, mais le code généré l'importe | À régler en phase 4, sinon le build échoue sur un clone neuf |
| Le préfixe `!` de Claude Code passe par Bash, qui retire les `\` d'une commande PowerShell | Lancer les scripts dans une fenêtre PowerShell séparée, surtout s'ils demandent une connexion par code |
| Une fonction PowerShell déroule un `byte[]` à sa sortie ; l'API répond « Stream was not readable » | Renvoyer le tableau avec `, [byte[]]...`. Une simulation ne révèle pas ce bug, car elle n'écrit rien |
| `Select-Object -First N` arrête le script en amont dès la N-ième ligne, même en pleine écriture | Rediriger la sortie vers un fichier. L'idempotence du script a permis de reprendre sans doublon |

### Prochaine étape

Phase 2 terminée. Prochaine étape : le plan de la phase 3 (sécurité), après l'accord de Gween.
Avant de la fusionner, tests verts : 27 tests unitaires, 12 tests Playwright, build. Détail de la
phase : application republiée et
vérifiée à l'écran (6 points), ADR 0003 mis à jour, `gk_dateecheance` confirmée modifiable,
`gk_daterappel` et `gk_ApprobateurProrogation` créées. Le flux 3 a été créé par code, désactivé, dans
la solution, à partir de `src/flows/approbation-prorogation.json`, puis relu dans le portail sans
rien enregistrer. Il est activé, et les tests de rejet et d'approbation sont réussis sur A-2026-01021,
qui est maintenant à « Prorogée » avec une échéance au 2026-12-06. `docs/flux.md` et l'ADR 0004 sont
à jour. Le 1er novembre, les flux 1 et 2 sont passés à la modification par code : le flux 1 écrit
« = no » (vérifié sur A-2026-01022, `ACT-01052`), le flux 2 utilise `gk_daterappel` et la variable
`gk_DestinataireRappels`. Le test du flux 2, lancé deux fois, a créé 12 cartons au premier passage et
aucun au second. Risque à contrôler avant la phase 4 : un enregistrement dans le portail pourrait
écrire une adresse dans un `defaultValue`.

Limite connue : la séparation des tâches n'est pas prouvée, car un seul compte réel demande et
approuve. Le blocage des statuts reste côté interface jusqu'aux rôles de la phase 3.

Décisions du 31 octobre sur le flux 3 : construction par code plutôt que dans le portail, retour à
la construction manuelle si la création échoue ou si le flux s'ouvre mal, activation seulement après
accord de Gween, vérification faite par l'assistant dans le navigateur plutôt que par Gween. Le flux 3
n'est jamais enregistré depuis le portail : toute modification passe par le JSON du dépôt, puis par
une mise à jour par code. En cas de rejet, le motif et l'échéance proposée sont inscrits au journal,
puis effacés de la demande ; en cas d'approbation, le motif reste dans la demande.

Pièges du flux 3 : la table `workflows` n'a pas de colonne `modeofexecution` ; le concepteur affiche
une ligne vide sous la condition `Decision` alors que le code ne contient qu'une comparaison ; la
table `flowrun` se remplit avec plusieurs minutes de retard ; une approbation répondue ne l'est
réellement que si `msdyn_flow_approval` est fermée (une première réponse n'a pas été enregistrée).

---

# Historique avant le programme de finalisation

## État par phase

- [x] **Phase 0** — Structure du dépôt, README FR/EN, architecture, `.gitignore`. Poussé sur GitHub.
- [x] **Phase 1** — Schéma Dataverse (`gk_demande`, `gk_activite`) créé par script, idempotent.
  15 demandes fictives + journal d'activité cohérent.
- [x] **Phase 2** — Pivot de canvas vers **code app React** (ADR 0002) en cours de route. 4 écrans
  fonctionnels (Tableau de bord, Liste, Détail, Nouvelle demande), bilinguisme FR/EN (contexte
  React, 68 clés), style GCDS, 12 tests Playwright + axe-core (zéro violation WCAG 2.1 AA). Vérifié
  manuellement dans le navigateur (`pa app run` + Local Play) avec un cycle complet de création.
- [~] **Phase 3** — Flux Power Automate, **en cours**. Voir détail ci-dessous.
- [ ] **Phase 4** — Sécurité et rôles (Agent AIPRP, Gestionnaire AIPRP) — pas commencée.
- [ ] **Phase 5** — ALM et GitHub Actions — pas commencée.
- [ ] **Phase 6** — Tests d'accessibilité manuels complémentaires (lecteur d'écran, contraste) — pas
  commencée (les tests automatisés de la Phase 2 couvrent déjà une bonne partie).
- [ ] **Phase 7** — Documentation finale, captures, étude de cas, `entrevue.md` — pas commencée.

## Détail Phase 3 — Flux Power Automate

| Flux | Statut |
|---|---|
| 1. Demande reçue (accusé de réception conditionnel) | ✅ Construit, activé, **les deux branches testées et confirmées** (voir résultats plus bas). |
| 2. Rappel quotidien des échéances | ✅ Construit, activé, **testé avec succès** (exécution manuelle, 3 cartes de rappel créées — voir `docs/flux.md`). |
| 3. Approbation de prorogation | Spécifié dans `docs/flux.md` (avec le statut *Prorogation demandée* ajouté), pas encore construit. |

Travail côté script/app déjà fait pour la Phase 3 :
- Statut `gk_statut = 100000015` (*Prorogation demandée*) ajouté à Dataverse — voir
  [ADR 0003](adr/0003-approbation-prorogation-par-flux.md).
- `app/src/pages/Detail.tsx` : le bouton « Approuver la prorogation » est retiré ; seul le flux 3
  peut approuver (séparation des tâches).
- Variable d'environnement `gk_EnvoiCourrielActif` (Booléen) créée pour activer/désactiver l'envoi
  de courriel sans modifier le flux 1.

### Résultats des tests — Flux 1, les deux branches

| Test | Variable | Demande de test | Résultat |
|---|---|---|---|
| Branche Si Non | `no` | « TEST FLUX 1 - Sans courriel 3 » | ✅ Activité `ACT-01038` créée en quelques secondes : « Envoi de courriel désactivé (variable d'environnement gk_EnvoiCourrielActif = false). » |
| Branche Si Oui | `yes` | « TEST FLUX 1 - Avec courriel » | ✅ Activité `ACT-01039` créée en quelques secondes : « Accusé de réception envoyé par courriel au demandeur (voir l'historique du flux pour le résultat). » |

✅ Les deux branches sont confirmées fonctionnelles. (Note : le texte du commentaire de la branche
Si Non dans le flux dit encore « = false » au lieu de « = no » — cosmétique seulement, aucun impact
fonctionnel.) Variable remise à `no` après le test (pas de boîte aux lettres réelle dans cet
environnement de développement) ; flux désactivé/réactivé pour appliquer le changement.

### Résultat du test — Flux 2, exécution manuelle

Exécuté manuellement sur les données de démo existantes (aucune donnée de test à créer, contrairement
au flux 1) : ✅ 3 demandes actives correspondaient au filtre (agent assigné + échéance ≤ 5 jours,
retard inclus) et 3 cartes « Rappel echeance - A-2026-... » sont apparues dans le centre
**Approbations**.

## Pièges rencontrés et solutions

| Piège | Contexte | Solution |
|---|---|---|
| **Séparateurs Power Fx en locale française** | Studio de Gween est en français : `,` devient `;` (arguments), `;` devient `;;` (instructions chaînées) — utilisé au départ pour l'itération canvas | Toutes les formules du dépôt (archivées dans `docs/archive/powerfx-canvas/`) écrites avec la syntaxe française dès le départ. Note dans `powerfx/README.md` (archivé). N'affecte plus le projet depuis le pivot vers la code app (Phase 2), qui n'utilise pas Power Fx. |
| **`parameters()` non déclaré** | En construisant le flux 1, la variable d'environnement n'apparaissait pas du premier coup dans le contenu dynamique ; une expression `parameters('Envoi de courriel actif (gk_EnvoiCourrielActif)')` tapée à la main a échoué à l'exécution (*"The workflow parameter ... is not found"*) car ce paramètre n'était déclaré nulle part dans la définition du flux | Ne jamais deviner une expression Power Automate à la main. Rouvrir l'étape/le flux et rechercher à nouveau dans le contenu dynamique (elle finit par apparaître), ou utiliser `environmentVariables('schemaname')` dans l'onglet Expression. Documenté dans `docs/flux.md` (« Pièges rencontrés en testant »). |
| **Variable Booléen : stockage `yes`/`no` vs comparaison `true`/`false`** | `scripts/New-EnvironmentVariable.ps1` créait la variable avec `defaultvalue = "false"` — accepté sans erreur par l'API, mais mal interprété par le portail (affichait « Non » indépendamment de la valeur écrite) | Deux couches distinctes : le **stockage** Dataverse d'une variable Booléen utilise le texte `yes`/`no` (script corrigé pour écrire `"no"`) ; la **comparaison** dans une condition de flux, une fois la variable lue comme booléen typé par Power Automate, utilise `true`/`false` (littéraux du langage d'expression). Les deux sont documentées séparément dans `docs/flux.md` pour ne pas les confondre. |
| **Office 365 Outlook indisponible → connecteur Mail** | Pas de licence Exchange/Outlook dans ce tenant de développement (limite connue depuis le début du projet) | Le connecteur **Mail** (`Send an email from your own email address`) envoie depuis une adresse générée par Microsoft, sans boîte aux lettres requise — utilisé à la place d'Office 365 Outlook dans le flux 1 pour un envoi réellement fonctionnel. Documenté dans `docs/flux.md`, à l'étape 5.1 du flux 1. |
| **Un flux activé ne relit pas une variable d'environnement modifiée** | En testant la branche Si Oui, un flux déjà activé peut continuer à utiliser l'ancienne valeur de la variable après qu'elle ait été changée dans le portail | Désactiver puis réactiver le flux après tout changement de valeur d'une variable d'environnement qu'il consulte. Documenté dans `docs/flux.md`, section « Variable d'environnement gk_EnvoiCourrielActif ». |
| Nom de code app en conflit avec l'app canvas existante | `pa app push` a échoué : `ApplicationDisplayNameIsInUse` — l'app canvas de l'itération abandonnée portait déjà le nom « Suivi AIPRP » | Renommage temporaire de la code app (`power.config.json` local, non commité) en « Suivi AIPRP (code app - dev) ». Renommage définitif prévu au ménage final (Phase 7), après suppression de l'app canvas. |
| Version périmée du CLI `pa` / Node.js trop ancien | `npm install -g @microsoft/power-apps-cli` installait la 0.6.7 (structure de commandes différente, pas `pa app init`) ; la version 1.0.2 exige Node ≥ 22, on avait Node 20 | Réinstallation explicite en version 1.0.2 + mise à jour de Node vers la 22 via `nvm`. |
| `GcdsButton` ne met pas à jour son `aria-label` après le rendu initial | Découvert par le premier échec d'un test Playwright (pas un bug de test) : après bascule de langue, le bouton gardait l'ancien `aria-label` — un vrai problème d'accessibilité | `key={langue}` sur le composant pour forcer React à le remonter à chaque changement de langue. Documenté dans `docs/accessibilite.md`. |
| GCDS charge des polices externes (Google Fonts, CDN GC) | La CSP par défaut des code apps (`font-src 'self'`, depuis le 30 janvier 2026) bloque ces origines | Accepté comme repli gracieux vers la police système ; documenté dans `docs/adr/0002-canvas-vs-code-app.md` et `app/src/index.css`. |
| Nom d'étape contenant `?` | En construisant le flux 2, nommer la condition « Agent assigné ? » a échoué à l'enregistrement (*InvalidWorkflowRunActionName*) | Les noms d'étapes Power Automate n'acceptent pas la ponctuation comme `?` — renommée « Agent assigné » (sans point d'interrogation). Documenté dans `docs/flux.md`. |
| Condition sur un lookup vide : `null` vs texte `"null"` | La condition « Agent assigné » du flux 2 comparait le champ de référence à la chaîne `"null"`, qui ne correspond jamais à une valeur vide | Utiliser le littéral d'expression `null` (sans guillemets) dans l'onglet Expression, pas le texte `"null"`. Documenté dans `docs/flux.md`. |
| `AssignedToMissing` sur une action Standard Approvals | L'ancien concepteur (design classique) du flux 2 n'enregistrait pas toujours les champs de l'action « Créer une approbation », causant *InvalidApprovalCreateRequestAssignedToMissing* à l'exécution malgré un champ « Attribuer à » visuellement rempli | Supprimer l'action et la recréer (plutôt que rouvrir/re-remplir), puis vérifier avec **Lire le code** (`</>`) que `assignedTo` apparaît dans le JSON avant d'enregistrer. Documenté dans `docs/flux.md`. |

## Nettoyage des données de test

✅ Les 4 demandes de test du flux 1 (`A-2026-01017` à `01020`) et leurs activités liées ont été
supprimées après la fin des tests (données fictives, aucune valeur pour la démo finale).
