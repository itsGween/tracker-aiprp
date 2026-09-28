# Sécurité

## Licence — code app (préversion)

Le front-end est une **Power Apps code app**, hébergée et gouvernée par Power Platform
(authentification Microsoft Entra, connecteurs, DLP).

- **Développement et tests** : entièrement couverts par le [Power Apps Developer Plan](https://learn.microsoft.com/power-platform/developer/plan) — aucun coût.
- **Utilisateurs finaux** (en production) : ont besoin de l'une des options suivantes pour lancer
  l'application —
  - une licence **Power Apps Premium** ;
  - un accès facturé à l'utilisation (*pay-as-you-go*) ;
  - un *App Pass* ;
  - l'attribution automatique (*auto-claim*), si une licence premium est disponible dans le tenant.

Cette exigence vient du fait que la code app utilise Dataverse, une source de données premium —
voir [licence Power Apps](https://learn.microsoft.com/power-platform/admin/powerapps-licensing-faq).
Pour ce projet de démonstration à données fictives, seul le Developer Plan est nécessaire.

🚧 **Reste à venir — Phase 4.**

Ce document décrira aussi :

- les deux rôles de sécurité Dataverse (Agent AIPRP, Gestionnaire AIPRP) et leurs privilèges exacts par table ;
- le principe de moindre privilège appliqué à chaque rôle ;
- la gestion de la classification des demandes (Non classifié, Protégé A, Protégé B) ;
- les limites d'un environnement de développement Power Platform par rapport à un environnement réellement homologué Protégé B (ce projet reste une démonstration à données fictives, non destiné à des renseignements réels).

Voir la décision de plateforme dans [ADR 0001](adr/0001-dataverse-vs-sharepoint.md).
