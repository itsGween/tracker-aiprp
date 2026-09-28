# tests/

Tests Playwright + axe-core (`npm run test:e2e`).

## Portée et limite connue

Ces tests lancent le serveur de développement Vite directement (`http://localhost:5173`), **sans
passer par l'hôte Power Apps**. C'est une limite volontaire, pas un oubli :

- Le client Dataverse (`@microsoft/power-apps/data`) a besoin de l'hôte Power Apps (obtenu via
  `pa app run` + le lien « Local Play », qui passe par une authentification Microsoft Entra
  interactive) pour résoudre les appels de données. Sans cet hôte, les appels `getAll()`/`get()`
  restent en attente indéfiniment.
- Automatiser une vraie connexion Entra dans une suite Playwright (état de session stocké, jetons
  qui expirent, MFA) dépasse la portée de ce projet de démonstration et introduirait une gestion de
  secrets disproportionnée pour une app à données fictives.

**Ce qui est donc couvert automatiquement :**
- Structure sémantique, lien d'évitement, navigation clavier, bascule FR/EN — sur les 4 écrans
- Le formulaire **Nouvelle demande** en entier (c'est le seul écran qui ne charge pas de données à
  l'affichage) : validation, résumé d'erreurs, absence de violation axe-core
- L'état de chargement des 3 écrans branchés sur Dataverse (tableau de bord, liste, détail) : aucune
  violation axe-core sur ce qui s'affiche réellement sans hôte

**Ce qui ne l'est pas (vérifié manuellement à la place) :**
- Les 3 écrans branchés sur Dataverse une fois les données chargées (tableau de bord avec les
  compteurs, liste remplie, détail d'une demande) — vérifiés manuellement dans le navigateur via
  `pa app run` + Local Play pendant la Phase 2 (voir captures dans l'historique de conversation ;
  captures figées à ajouter dans `docs/guide-utilisateur.md` en Phase 7)

Amélioration possible pour une couverture complète : capturer un `storageState` Playwright à partir
d'une session Local Play authentifiée (secret CI à gérer), ou construire une couche de simulation
pour `Gk_demandesService`/`Gk_activitesService`.
