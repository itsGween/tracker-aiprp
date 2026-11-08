# Document de reprise — Suivi AIPRP

> **À jour au 8 novembre 2026 (essai créé).** Ce document permet de reprendre le projet sans aucun historique de
> conversation. Il est mis à jour à la fin de chaque étape (point 4 de la routine de fin de phase).
> Le détail complet reste dans [`progression.md`](progression.md).

## 1. Le projet en bref

**Objectif** : application de suivi des demandes d'accès à l'information et de protection des
renseignements personnels (AIPRP) pour un bureau fédéral fictif : réception, échéance légale de
30 jours, prorogations approuvées, journal d'activité, interface bilingue FR/EN et accessible
(WCAG 2.1 AA, style GCDS). Projet de portfolio Power Platform de Gween, à présenter en entrevue.

**Dépôt** : <https://github.com/itsGween/tracker-aiprp> (public). Branche principale : `main`.

| Élément | Détail |
|---|---|
| Interface | Power Apps **code app** React + TypeScript + Vite (`app/`), 4 écrans : tableau de bord, liste, détail, nouvelle demande |
| Données | Dataverse, tables `gk_demande` et `gk_activite` (préfixe d'éditeur **`gk`**) |
| Automatisation | 3 flux Power Automate, définitions dans `src/flows/*.json` : 1. Demande reçue (accusé de réception), 2. Rappel quotidien des échéances, 3. Approbation de prorogation |
| Solution | **SuiviAIPRP**, dépaquetée dans `src/solution/`, exports dans `out/solution/` (hors Git) |
| Variables d'environnement | `gk_EnvoiCourrielActif`, `gk_ApprobateurProrogation`, `gk_DestinataireRappels` |
| Scripts | PowerShell dans `scripts/` (schéma, données de démo, export/import, mise à jour des flux) |
| Décisions d'architecture | `docs/adr/` (0001 à 0004 ; 0005 rôles et 0006 mode démo à venir) |
| Outils | PAC CLI 2.12.2 (outil global dotnet), CLI `pa` 1.0.2, Node 22, Vitest, Playwright + axe-core |

## 2. État des phases et des étapes

Le programme de finalisation (depuis le 31 octobre 2026) a sa propre numérotation, distincte de
l'historique plus ancien décrit au bas de `progression.md`.

| Phase / étape | État | Branche, commits |
|---|---|---|
| Phase 1 — Stabiliser l'application | ✅ Terminée, publiée, vérifiée | `phase-1/stabilisation`, fusion `aec292c`, `53e1a7f` |
| Phase 2 — Flux 3 et améliorations des flux 1 et 2 | ✅ Terminée le 1er nov. | `phase-2/flux-prorogation`, fusion `2cf647b` |
| Phase 3 — Sécurité (rôles Agent et Gestionnaire AIPRP, plug-in C#, sécurité de colonne) | ⬜ À faire, prévue le **1er déc.** | — |
| Phase 4 — ALM (solution dépaquetée, déploiement, GitHub Actions) | 🟨 En cours (sauvegarde faite, redéploiement en cours) | `phase-4/alm-sauvegarde` (`e42ec6c`, fusion `c7daf00`), `phase-4/redeploiement` |
| Phase 5 — Accessibilité (axe-core étendu, tests manuels) | ⬜ À faire, sans échéance stricte | — |
| Phase 6 — Documentation pro, MkDocs, v1.0.0, typographie française | ⬜ À faire | — |
| Phase 7 — Ménage de l'environnement, accents, rafraîchissement des dates | ⬜ À faire (ménage partiel le 3 déc.) | — |
| Phase 8 — Portfolio gweenkangah.pro | ⛔ Retirée le 4 nov. (Gween déploiera elle-même) | — |
| Étape A — Fusion dans `main`, README à jour | ✅ Faite le 3 nov. | `c7daf00`, `263bd29` |
| Étape B — Portfolio | ⛔ Annulée le 4 nov., tout retiré et vérifié | `70872f7` (décisions consignées) |
| C1 — Recherche sur l'environnement d'essai (lecture seule) | ✅ Faite le 4 nov. | `docs/etape-c1`, `1c44055`, fusion `a27bb3f` |
| C2 — Scripts capables de viser un autre environnement | ✅ Terminée le 8 nov. : scripts testés, `scripts/.env.essai` et `deploy/settings.essai.json` créés (ignorés par Git) | `phase-4/redeploiement`, `e0b2857`, `3734671` (poussés, **pas fusionnés**) |
| C3 — Création de l'environnement d'essai et des connexions | ✅ Faite le 8 nov. par Gween : essai créé et vérifié, code apps activées, connexions Dataverse et Approbations. **Mail impossible** : connecteur restreint pour les nouveaux environnements (voir `installation.md`) | — |
| C4 — Test réel : import de la solution gérée, données, publication de l'app | ⬜ À faire | — |
| C5 — `docs/installation.md`, `deploy/README.md`, `alm.md` | ⬜ À faire | — |
| C6 — Routine en 7 points, fusion dans `main` | ⬜ À faire, échéance de l'étape C : **13 nov.** | — |

Séquence d'urgence avant le 15 déc. (acceptée le 1er nov.) :

- [x] Étape 0 — Vérification du type d'environnement (Développeur, non géré).
- [x] Étape 1 — Sauvegarde : solution, données de démo, paramètres (`e42ec6c`), revérifiée le 2 nov.
- [ ] Étape 2 — Captures et vidéo : 01 à 07 et 09 à 16 faites ; restent 08, 17 à 19 (phase 3), la
  vidéo et les captures à refaire.
- [x] Étape 3 — Mode démo évalué (environ 2 jours), accepté pour le 11 au 19 déc.
- [ ] Étape 4 — Installation et test réel du redéploiement (= étape C).
- [x] Étape 5 — Calendrier fixé le 2 nov.

## 3. Ce qui fonctionne et a été testé

| Élément | Preuve |
|---|---|
| Tests automatisés | 27 tests unitaires Vitest (fuseau `America/Toronto`), 12 tests Playwright avec axe-core (zéro violation WCAG 2.1 AA), lint et build verts à la fin de la phase 2 |
| Application publiée | Vérifiée à l'écran le 31 oct. : compteurs du tableau de bord, encadré « En retard », échéances identiques à Dataverse, heures du journal, auteur (`WhoAmI`), bascule en anglais. Republiée et revérifiée en phase 2 (6 points) |
| Flux 1 — Demande reçue | Les deux branches testées (`ACT-01038` sans courriel, `ACT-01039` avec courriel) ; texte « = no » vérifié sur A-2026-01022 (`ACT-01052`) |
| Flux 2 — Rappel quotidien | Test anti-doublon : 12 cartons au premier passage, aucun au second (colonne `gk_daterappel`) |
| Flux 3 — Approbation de prorogation | Créé par code, tests de rejet et d'approbation réussis sur A-2026-01021, maintenant « Prorogée », échéance au 2026-12-06 |
| Correction des données | `Repair-DonneesDemo.ps1` : 1 demande modifiée, 1 activité ajoutée, 37 activités déplacées à midi, 0 suppression, relu dans Dataverse |
| Sauvegarde | Export du 2 nov. identique à un nouvel export : 53 fichiers sur 53, 15 demandes, 39 activités |
| Garde-fous de C2 | Aucune erreur de syntaxe ; `-Importer` sans `-Cible` refusé ; mauvais environnement refusé avant toute écriture |
| Jamais testé pour de vrai | `Import-DonneesDemo.ps1 -Importer` et l'import de la solution gérée dans un autre environnement : c'est l'objet de C4 |

Limite connue : la séparation des tâches n'est pas prouvée (un seul compte réel demande et
approuve) ; le blocage des statuts reste côté interface jusqu'aux rôles de la phase 3.

## 4. Décisions de Gween

| Date | Sujet | Décision |
|---|---|---|
| 31 oct. | Liste des statuts | « Prorogation demandée » posé seulement par le bouton, « Prorogée » seulement par le flux 3 (ADR 0003) |
| 31 oct. | A-2026-01003 | Remise à « En traitement » par script, avec une entrée au journal |
| 31 oct. | Activités de démo | Déplacées à midi ; `New-DemoData.ps1` corrigé ; rien d'autre ne change dans les 15 demandes |
| 31 oct. | `.power/` | Versionner s'il ne contient ni identifiant ni secret (option : seulement `dataSourcesInfo.ts`, à confirmer) |
| 31 oct. | Plan de la phase 2 | Approuvé (8 points) |
| 31 oct. | Rappels du flux 2 | Un seul rappel par échéance, colonne `gk_daterappel` |
| 31 oct. | Approbateur du flux 3 | Variable `gk_ApprobateurProrogation`, aucun compte réel dans le dépôt |
| 31 oct. | Tests de prorogation | **Uniquement sur A-2026-01021** |
| 31 oct. | Section « Demander une prorogation » | Affichée seulement au statut « En traitement » |
| 31 oct. | Journal contenant « = false » | Données historiques non modifiées ; seul le texte du flux 1 corrigé |
| 31 oct. | Flux 3 | Construit par code ; activé seulement avec l'accord de Gween ; jamais enregistré depuis le portail |
| 31 oct. | Ajouts à la phase 7 | Accents des données de démo, script de rafraîchissement des dates |
| 2 nov. | A-2026-01021 | Supprimée à la fin des tests de la phase 3, avant de refaire les captures |
| 2 nov. | Calendrier | Phase 3 le 1er déc., ménage le 3, captures le 5, vidéo le 8, dernier export le 10 |
| 2 nov. | Fichiers hors Git | Copiés dans un dossier privé du OneDrive de Gween |
| 2 nov. | Mode démo | Accepté, codé du 11 au 19 déc. avec l'ADR 0006 |
| 4 nov. | Portfolio | Retour à l'état initial ; phase 8 et étape B retirées ; Gween déploiera elle-même |
| 4 nov. | Vitrine du projet | Tout reste sur GitHub ; `docs/portfolio-etude-de-cas.md` devient une étude de cas complète FR et EN, avec captures, sans renvoi vers le site |
| 4 nov. | Routine de fin de phase | 7 points (point portfolio retiré) |
| 4 nov. | Mode démo | Construit et documenté, **pas déployé sur Vercel** |
| 4 nov. | Étape C : cible | Environnement d'**essai** standard (scénario de réinstallation en entrevue) ; repli 2e Développeur avant le 15 nov. seulement en cas de blocage en C1 (aucun blocage trouvé) |
| 4 nov. | Étape C : création et import | Par l'assistant avec `pac admin create`, après avoir montré la commande ; connexions créées par Gween ; solution **gérée** ; cible gardée jusqu'à son expiration ou le 10 déc. |
| 4 nov. | Étude de cas complète | Du 14 au 20 nov. |
| 6 nov. | Test de l'essai | Fait tout de suite, même si les minuteries tournent ; dates d'expiration notées et rappels prévus |
| 8 nov. | Document de reprise | `docs/reprise.md` créé, mis à jour à la fin de chaque étape, PDF dans OneDrive |

## 5. Règles à respecter

- [ ] **Plan avant chaque phase ou étape**, et accord de Gween avant de coder. À la fin : résumé et
  3 points d'entrevue.
- [ ] **Jamais enregistrer un flux depuis le portail.** Toute modification passe par
  `src/flows/*.json`, puis `scripts/Update-Flux.ps1`. Dans le concepteur, sortir par « Précédent ».
- [ ] **Navigation dans les portails en lecture seule** : ne jamais cliquer sur Enregistrer, Activer,
  Désactiver, Supprimer ou Exécuter.
- [ ] **Jamais retirer le rôle d'administrateur système** du compte de Gween.
- [ ] **Tests de prorogation uniquement sur A-2026-01021.**
- [ ] **Rien supprimer sans l'accord explicite de Gween** (fichiers, données, composants Power
  Platform). Les 15 demandes de démo (A-2026-01001 à 01015) restent intactes.
- [ ] **Aucun identifiant ni secret dans le dépôt** : ni ID de locataire ou d'environnement, ni vrai
  courriel. Ne pas les afficher non plus dans le terminal ni dans les captures.
- [ ] **Captures** : aucune adresse courriel, aucun identifiant, pas de barre d'adresse, jamais le
  panneau « Références de connexion ».
- [ ] **Connexion ou acceptation demandée** à l'écran : s'arrêter et prévenir Gween.
- [ ] **Une branche par phase**, Conventional Commits, fusion dans `main` puis push.
- [ ] **`docs/audit.md` n'est jamais commité.**
- [ ] **Le portfolio, c'est Gween qui le déploiera** : ne pas toucher à `itsGween/portfolio`,
  `itsGween/itsGween`, `portfolio-pro`, `MyPortfolio`, ni à Vercel.
- [ ] Mettre à jour `progression.md` et ce document à la fin de chaque étape et avant une compaction.

**Routine de fin de phase (7 points)** :

1. **Tests** : lint, build, tests unitaires, Playwright.
2. **Sauvegarde** : réexporter (non gérée et gérée), dépaqueter, comparer ; lister les fichiers hors
   Git à recopier dans `OneDrive\Sauvegardes\SuiviAIPRP`.
3. **Captures** des nouveautés, puis `docs/captures.md`.
4. **Documentation** : README FR et EN, documents concernés, `progression.md` et **`reprise.md`**.
5. **GitHub** : fusion dans `main`, push.
6. **Déploiement** : republier l'application si son code a changé, vérifier qu'elle s'ouvre.
7. **Résumé** : fait, reste, 3 points d'entrevue.

## 6. Pièges rencontrés et solutions

| Piège | Solution |
|---|---|
| `pac admin create` : `macroRegion 'canada' is not valid` | Bogue de PAC CLI (microsoft/powerplatform-vscode#1678), corrigé en 2.15 (pas encore publiée ; dernière : 2.14.1). Créer l'essai dans le centre d'administration, ou attendre la 2.15. Ne pas deviner `--macro-region` |
| Jeton en cache unique : un import vers l'essai aurait pu écrire dans la source | Cache par environnement et garde-fou `-Cible` (C2). La source redemande une connexion une fois |
| `new Date("AAAA-MM-JJ")` donne la veille à Ottawa ; `toISOString()` donne demain après 20 h | Calculer sur la partie `AAAA-MM-JJ` ; date du jour à partir de l'heure locale ; `ajouterJours` en UTC |
| `getContext()` donne l'ID Entra, pas le `systemuserid` | Appeler `WhoAmI` |
| `pa app push --non-interactive` exige l'environnement | Définir `PA_CLI_ENVIRONMENT_ID` depuis `power.config.json`, sans l'afficher |
| `.power/` ignoré par Git alors que le code généré l'importe | Copie dans OneDrive ; à régler en phase 4 |
| Le préfixe `!` passe par Bash et retire les `\` | Lancer les scripts avec connexion par code dans une fenêtre PowerShell séparée |
| `byte[]` déroulé à la sortie d'une fonction (« Stream was not readable ») | Renvoyer `, [byte[]]...` |
| `Select-Object -First N` arrête le script en amont | Rediriger la sortie vers un fichier |
| `pac env fetch` : XML en texte, attribut `top` refusé | `--xmlFile` avec chemin Windows ; retirer `top` |
| Variable Booléen : stockage `yes`/`no`, comparaison `true`/`false` | Écrire `"no"` ; comparer avec les littéraux du langage d'expression |
| Un flux activé ne relit pas une variable modifiée | Désactiver puis réactiver le flux (par code) |
| `parameters()` deviné à la main échoue | Utiliser le contenu dynamique ou `environmentVariables('schemaname')` |
| Office 365 Outlook indisponible | Connecteur **Mail** dans le flux 1 |
| Nom d'étape avec `?` refusé ; lookup vide comparé à `"null"` | Pas de ponctuation ; littéral `null` |
| `AssignedToMissing` sur une approbation | Recréer l'action et vérifier `assignedTo` dans le code |
| Approbation répondue mais non enregistrée | Vérifier que `msdyn_flow_approval` est fermée ; `flowrun` se remplit en retard |
| Dans le nouveau concepteur, déplier une branche active Enregistrer | Sortir par « Précédent » |
| Export non géré seul : dépendance `systemuser` (`msdyn_PowerAdminSettingsEmail`) | À surveiller pendant l'import de C4 |
| `ApplicationDisplayNameIsInUse` (ancienne app canvas) | Code app nommée « Suivi AIPRP (code app - dev) » localement ; renommage en phase 7 |
| CSP des code apps bloque les polices GCDS | Repli vers la police système, documenté dans l'ADR 0002 |
| `GcdsButton` ne met pas à jour son `aria-label` | `key={langue}` |
| Captures Playwright locales vides | Capturer les écrans remplis dans l'application publiée |
| Connecteur Mail absent d'un environnement neuf (« restreint pour les nouveaux locataires et les nouvelles régions ») | Référence `gk_sharedsendmail_577cd` laissée vide ; le flux 1 ne peut pas s'activer ; options dans `installation.md` |
| « Activer les code apps » n'est pas dans la table `organization` | Bascule dans le centre d'administration, ou réglage `powerApps_AllowCodeApps` de l'API Power Platform |
| Aperçu Vercel protégé (Lighthouse, page de connexion) | Mesurer le même build localement ; fermer l'onglet de connexion |
| Guillemets de `gh --jq` en PowerShell | Lancer `gh` dans Bash |

## 7. Environnements et licences

| Élément | État | Dates |
|---|---|---|
| Environnement source « Environnement de Gween Kangah » | Développeur, **non géré**, région Canada, langue 1036, contient tout le projet | **Suspendu le 15 déc. 2026**, supprimé le 15 janv. 2027. Plus de création de Développeur non géré après le 15 nov. 2026 |
| Environnement d'essai « Suivi AIPRP - essai » | **Créé le 8 nov. 2026** par Gween dans le centre d'administration (après l'échec de `pac admin create`). Vérifié : type `Trial`, Canada (`crm3`), langue 1036, état Prêt | **Expire vers le 7 déc. 2026** (29 jours restants le 8 nov.). Une seule prolongation de 30 jours, **seulement dans les 7 derniers jours : entre le 1er et le 6 déc.** |
| Licence « PowerApps Trial » de Gween | Obtenue le 6 nov. 2026 | **Expire le 6 déc. 2026**, prolongeable par tranches de 30 jours jusqu'à 90 jours au total (vers le 4 févr. 2027) |

Paramètres prévus pour l'essai : type Essai, région Canada, Dataverse oui, langue Français (1036),
devise CAD, URL `suiviaiprp-essai`, applications Dynamics 365 non, groupe de sécurité aucun. Après
création : activer « Activer les code apps », créer les connexions Dataverse, Approbations et Mail.

**Prolongations à ne pas manquer** :

- [ ] **À partir du 29 nov.** : le rappeler à Gween au début de chaque séance.
- [ ] **Entre le 1er et le 6 déc.** : prolonger l'environnement d'essai (« Prolonger l'essai » dans
  le centre d'administration ; vérifier la date exacte d'expiration dans ses détails).
- [ ] **Le 6 déc.** : accepter la prolongation de la licence « PowerApps Trial ».
- [x] Date de création de l'essai notée (8 nov. 2026).

## 8. Calendrier jusqu'au 19 décembre

| Date | Travail | Échéance |
|---|---|---|
| 8 → 13 nov. | Étape C : création de l'essai (C3), test réel (C4), documentation (C5), routine (C6) | **13 nov.** |
| 15 nov. | Plus de création d'environnement Développeur non géré | Fixe |
| 14 → 20 nov. | Étude de cas complète FR et EN dans `docs/portfolio-etude-de-cas.md` | **20 nov.** |
| 29 nov. → 6 déc. | Prolongations : environnement d'essai entre le 1er et le 6 déc., licence le 6 déc. | **6 déc.** |
| 1er déc. | Phase 3 (sécurité), captures 08 et 17, puis 18 et 19 | 1er déc. |
| 3 déc. | Ménage des données, avec accord pour chaque suppression | 3 déc. |
| 5 déc. | Refaire les captures 01, 02, 03, 03b, 06 et 14 | 5 déc. |
| 8 déc. | Vidéo commentée, YouTube « non répertoriée », original dans OneDrive | 8 déc. |
| 10 déc. | Dernier export, comparaison, copie OneDrive, vérification du redéploiement ; décision de Gween sur l'essai | **10 déc.** |
| 11 → 19 déc. | Mode démo autonome (ADR 0006), construit et documenté, **non déployé** | 19 déc. |
| 15 déc. | Suspension de l'environnement source | Fixe |

## 9. Fichiers hors de Git et sauvegarde

Emplacement de la sauvegarde : `C:\Users\kanga\OneDrive\Sauvegardes\SuiviAIPRP` (dossier privé).
Ne jamais afficher le contenu de ces fichiers.

| Fichier dans le dépôt local | Rôle | Copie OneDrive |
|---|---|---|
| `out/solution/SuiviAIPRP.zip` | Export non géré du 2 nov. | ✅ |
| `out/solution/SuiviAIPRP_managed.zip` | Export géré du 2 nov. | ✅ |
| `deploy/settings.dev.json` | Paramètres de déploiement (comptes réels) | ✅ |
| `scripts/.env` | Connexion à l'environnement source | ✅ |
| `app/power.config.json` | Configuration locale de la code app | ✅ |
| `app/.power/` | Schémas générés, nécessaires au build | ✅ |
| `docs/audit.md` | Feuille de route de la finalisation (non commitée) | ✅ |
| `demo-suivi-aiprp-2026-11-02.gif` | Démonstration de secours | ✅ |
| `case-studies.ts.txt` | Texte de l'étude de cas préparé pour le portfolio | ✅ |
| `reprise-suivi-aiprp-AAAA-MM-JJ.pdf` | Version PDF de ce document | ✅ |
| `scripts/.env.essai` | Connexion à l'environnement d'essai (créé le 8 nov.) | ✅ |
| `deploy/settings.essai.json` | Paramètres de déploiement de l'essai (référence Mail et Office 365 vides) | ✅ |

## 10. Se reconnecter

Toutes les valeurs viennent des fichiers locaux ci-dessus ; ne pas les recopier dans le terminal
ni dans le dépôt.

```powershell
# PAC CLI (outil global dotnet)
pac --version
pac auth list                    # profils existants ; ne pas afficher les adresses
pac auth create                  # connexion interactive par Gween si aucun profil valide
pac admin list                   # environnements visibles (lecture seule)

# CLI pa de la code app
cd app
pa auth login                    # connexion interactive par Gween
npm run lint; npm run build; npm test; npm run test:e2e

# API Web Dataverse (jeton MSAL par code d'appareil, cache par environnement dans %TEMP%)
.\scripts\Connect-Dataverse.ps1                          # source, lit scripts\.env
.\scripts\Connect-Dataverse.ps1 -EnvFile scripts\.env.essai -Cible suiviaiprp-essai
```

Lancer les scripts qui demandent une connexion par code dans une **fenêtre PowerShell séparée**
(pas avec le préfixe `!`). Depuis le 6 nov., le cache a changé de nom : la source redemande une
connexion une fois.

## 11. Prochaine étape exacte

**État du dépôt** : branche `phase-4/redeploiement` (poussée, pas fusionnée), seul fichier non suivi
`docs/audit.md` (normal).

**En attente de l'action de Gween** :

- [x] Créer « Suivi AIPRP - essai » (fait le 8 nov., vérifié).
- [x] « Activer les code apps » (fait par Gween le 8 nov.).
- [x] Connexions Microsoft Dataverse et Approbations (Mail indisponible).
- [ ] Choisir quoi faire de la référence Mail pour l'import (options dans `installation.md`) et
  approuver le plan de C4.

**À faire en premier par l'assistant à la reprise** :

1. Relire `docs/progression.md` et ce document ; si on est le 29 nov. ou après, rappeler les
   prolongations avant toute autre chose.
2. Vérifier `git status` et la branche `phase-4/redeploiement`.
3. Si le plan de C4 n'est pas encore approuvé, le représenter à Gween et attendre son accord.
4. Après l'accord, exécuter C4 : import de la solution gérée avec les paramètres,
   contrôle des composants, variables, références de connexion et flux actifs,
   `Import-DonneesDemo.ps1 -EnvFile scripts\.env.essai -Cible suiviaiprp-essai -Importer`
   (15 demandes, 39 activités), `pa app push` vers l'essai, test du flux 1 seulement (flux 3
   vérifié actif, sans test de prorogation).
5. Puis C5 (documentation) et C6 (routine, fusion dans `main`) avant le 13 nov.

## 12. Message de reprise à copier

```text
Reprise du projet Suivi AIPRP (C:\Users\kanga\Desktop\tracker-aiprp). Lis d'abord
docs/reprise.md puis docs/progression.md, et respecte toutes les règles de la section 5
(plan et accord avant de coder, jamais d'enregistrement de flux depuis le portail, rien
supprimé sans accord, aucun identifiant ni secret). Réponds-moi en français, en me
tutoyant. Dis-moi où on en est, rappelle-moi les prolongations si on est le 29 novembre
ou après, puis propose la prochaine étape exacte de la section 11.
```
