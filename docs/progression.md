# Progression du projet

Document de suivi interne (équipe Gween + assistant), pas destiné à la doc publique finale — mais
gardé dans le dépôt comme trace du cheminement réel, utile pour l'entrevue et pour reprendre le
travail après une pause. Mis à jour au fil des phases.

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

## Prochaines étapes

1. Construire le flux 3 (Approbation de prorogation) à partir de `docs/flux.md`.
2. Tester le flux 3 de bout en bout : demander une prorogation dans l'app, approuver dans le centre
   d'approbations Power Automate, vérifier le statut/l'échéance/le journal dans l'app.
3. Phase 4 — sécurité et rôles.
4. Ménage final (Phase 7) : supprimer l'app canvas, renommer la code app en « Suivi AIPRP » propre.

✅ Les 4 demandes de test du flux 1 (`A-2026-01017` à `01020`) et leurs activités liées ont été
supprimées après la fin des tests (données fictives, aucune valeur pour la démo finale).
