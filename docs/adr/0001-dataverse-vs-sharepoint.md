# 0001 — Dataverse plutôt que des listes SharePoint

## Statut

Acceptée

## Contexte

Le système doit stocker des demandes AIPRP et un journal d'activité lié, avec :

- une relation un-à-plusieurs entre une demande et ses activités ;
- une échéance calculée automatiquement (réception + 30 jours) qui doit rester cohérente sans logique applicative dupliquée ;
- un contrôle d'accès à granularité fine entre deux rôles (Agent AIPRP, Gestionnaire AIPRP) ;
- un cycle de vie ALM (export, vérification automatisée, déploiement entre environnements) reproductible par script, pour du CI/CD.

Deux options existent nativement dans Power Platform pour stocker ces données : des listes SharePoint, ou des tables Microsoft Dataverse.

## Options envisagées

**Option A — Listes SharePoint**
- ✅ Aucune licence supplémentaire requise ; familier pour beaucoup d'équipes GC.
- ❌ Pas de colonnes de formule server-side fiables pour calculer l'échéance (les formules de colonne SharePoint sont limitées et parfois recalculées côté client).
- ❌ Sécurité au niveau ligne limitée et peu adaptée à des rôles métier (Agent vs Gestionnaire) sans contournements.
- ❌ Pas de solution Power Platform native pour l'ALM — les listes ne se déploient pas proprement via `pac solution`.

**Option B — Microsoft Dataverse**
- ✅ Colonnes de formule calculées côté serveur (échéance = réception + 30 jours), fiables et non contournables par l'utilisateur.
- ✅ Rôles de sécurité Dataverse : contrôle par table, colonne et ligne, aligné avec le principe de moindre privilège demandé (Agent AIPRP / Gestionnaire AIPRP).
- ✅ Fait partie nativement d'une solution Power Platform : export, Solution Checker, packaging géré via `pac` et GitHub Actions.
- ✅ Relations table-à-table propres (`gk_demande` → `gk_activite`), avec intégrité référentielle.
- ❌ Nécessite un environnement avec base de données Dataverse provisionnée (disponible ici via le Power Apps Developer Plan, sans coût).
- ❌ Courbe d'apprentissage un peu plus élevée que des listes SharePoint.

## Décision

**Dataverse.** Les besoins de calcul fiable de l'échéance, de sécurité par rôle et d'ALM reproductible dépassent la simplicité initiale des listes SharePoint, et le Power Apps Developer Plan donne accès à Dataverse sans coût pour ce projet de démonstration.

## Conséquences

- L'environnement développeur doit avoir Dataverse provisionné (confirmé — voir vérification d'environnement en Phase 0).
- Le schéma des tables devient la source de vérité et doit être scripté (API Web ou `pac`) pour rester reproductible — voir [modele-donnees.md](../modele-donnees.md).
- Les rôles de sécurité Dataverse remplacent tout contrôle d'accès au niveau de l'application — voir [securite.md](../securite.md).
