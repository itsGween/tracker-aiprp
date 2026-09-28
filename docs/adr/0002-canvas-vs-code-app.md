# 0002 — Code app (React) plutôt que canvas

## Statut

Acceptée — remplace une décision initiale en faveur du canvas.

## Contexte

Une fois [Dataverse choisi comme source de données](0001-dataverse-vs-sharepoint.md), une première
décision avait retenu une **application canvas** (Power Fx, Power Apps Studio) plutôt qu'une
application modèle-pilotée : contrôle fin sur la mise en page, bilinguisme simple à implémenter via
une table de traductions, et `AccessibleLabel`/`TabIndex` contrôlables explicitement pour
WCAG 2.1 AA. L'écran 1 (Tableau de bord) avait été entièrement spécifié et la formule `App.OnStart`
(62 clés de traduction FR/EN) testée avec succès dans Studio.

Ce travail est réel et archivé dans [docs/archive/powerfx-canvas/](../archive/), pas perdu — ce
document explique pourquoi le projet change de direction avant d'aller plus loin.

**Changement de direction** : Power Apps propose maintenant les **code apps** (préversion) — des
applications web React/Vue/etc. développées dans un IDE de code, hébergées et gouvernées par Power
Platform (authentification Entra, connecteurs, DLP, ALM) tout en gardant un contrôle total sur le
code. React + TypeScript + Vite est la stack principale de l'auteure, et c'est ce qu'elle pourra
défendre le plus solidement en entrevue.

## Options envisagées

**Option A — Continuer avec l'application canvas (Power Fx)**
- ✅ Déjà commencée, écran 1 fonctionnel et testé.
- ✅ Développement rapide, aucun outillage de build à gérer.
- ❌ Ne démontre pas la stack principale de l'auteure (React/TypeScript), recherchée pour les postes
  de développement visés.
- ❌ Outillage de test limité : pas de devtools JavaScript classiques, pas de tests automatisés
  type Playwright pour l'accessibilité.
- ❌ Le code (formules Power Fx) est peu portable en dehors de l'écosystème Power Apps.

**Option B — Code app (React + TypeScript + Vite)**
- ✅ Stack principale de l'auteure — démonstration directe de compétences transférables.
- ✅ Outillage complet : typage TypeScript, HMR Vite, tests automatisés (Playwright + axe-core pour
  l'accessibilité), écosystème npm.
- ✅ Reste hébergée et gouvernée par Power Platform (authentification Microsoft Entra, connecteurs,
  DLP, ALM via solution) — conserve les avantages de la plateforme gérée.
- ✅ React Router pour une navigation explicite et testable entre les quatre écrans.
- ❌ Fonctionnalité en préversion, soumise à changement.
- ❌ Licence **Power Apps Premium** requise pour les utilisateurs finaux (le Developer Plan ne
  couvre que le développement et les tests) — voir [securite.md](../securite.md).
- ❌ Content Security Policy stricte par défaut depuis le 30 janvier 2026 : les ressources externes
  (polices, scripts CDN) sont bloquées sauf configuration explicite par un·e administrateur·rice de
  l'environnement — a orienté le choix du système de style (voir conséquences).
- ❌ Reprend le travail déjà fait sur l'écran 1 canvas — archivé, pas perdu.

## Décision

**Code app (React + TypeScript + Vite).** L'alignement avec la stack principale de l'auteure et
l'objectif d'entrevue (pouvoir défendre chaque ligne de code) l'emportent sur le travail déjà investi
dans le canvas. Le projet reste entièrement sur Power Platform (Dataverse, solution, connecteurs,
gouvernance Entra) — seule la couche de présentation change.

## Conséquences

- `powerfx/` est archivé dans `docs/archive/powerfx-canvas/` ; le nouveau code vit dans `app/`
  (projet Vite/React, initialisé avec le CLI `pa` — voir [alm.md](../alm.md)).
- Les 62 clés de traduction FR/EN sont reprises telles quelles dans `app/src/i18n/traductions.ts`,
  consommées via un contexte React plutôt qu'une collection Power Fx.
- Le style visuel utilise le Système de design GC (GCDS) **empaqueté via npm** (Vite) plutôt que
  chargé depuis un CDN externe, pour rester sous la politique CSP par défaut (`font-src 'self'`)
  sans dépendre d'une configuration admin.
- Les tests d'accessibilité automatisés (Playwright + axe-core) remplacent la vérification manuelle
  des `AccessibleLabel` — un gain net par rapport au canvas.
- La licence Premium requise pour les utilisateurs finaux doit être documentée clairement dans le
  README, puisqu'elle diffère de l'application canvas (qui n'aurait pas nécessité Premium pour un
  usage aussi simple).
- L'application canvas existante reste dans l'environnement Dataverse jusqu'au ménage final
  (Phase 7), où elle sera supprimée.
