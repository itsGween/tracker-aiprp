# 0003 — L'approbation de prorogation se fait par flux, pas par bouton dans l'app

## Statut

Acceptée

## Contexte

En Phase 2, l'écran Détail permettait à quiconque de cliquer à la fois sur « Demander une
prorogation » (fixe le nouveau statut, le motif, la nouvelle échéance proposée) et sur « Approuver
la prorogation » (applique immédiatement la nouvelle échéance). Les rôles de sécurité (Phase 4,
Agent AIPRP vs Gestionnaire AIPRP) n'existaient pas encore, donc aucune règle n'empêchait un Agent
d'approuver sa propre demande.

En Phase 3 (flux Power Automate), le projet ajoute un connecteur **Standard approvals**
(`shared_approvals`), qui fonctionne sans licence Exchange/Outlook et offre un vrai mécanisme
d'approbation avec un·e assigné·e distinct·e du demandeur.

## Options envisagées

**Option A — Garder le bouton « Approuver » dans l'app, ajouter le flux en parallèle**
- ✅ Aucun changement au code de la Phase 2.
- ✅ Permet une démo rapide sans attendre une vraie approbation.
- ❌ Deux chemins peuvent modifier la même ligne (le bouton et le flux) — risque de conflit ou de
  double mise à jour si les deux sont déclenchés presque en même temps.
- ❌ Ne démontre pas de séparation des tâches réelle ; le bouton reste un moyen de contourner
  l'approbation.

**Option B — Retirer la logique d'approbation de l'app ; le flux devient le seul chemin**
- ✅ Séparation des tâches réelle et vérifiable : l'app peut seulement *demander*, jamais
  *approuver*. Aligné avec le principe de moindre privilège déjà visé pour les rôles de sécurité
  (Phase 4).
- ✅ Une seule source de vérité qui modifie `gk_dateecheance`/`gk_statut` après une demande de
  prorogation — pas de risque de conflit.
- ✅ Meilleure démonstration des compétences Power Automate (connecteur Approvals) en entrevue.
- ❌ Touche du code déjà fonctionnel et testé (Phase 2).
- ❌ Sans boîte Outlook, l'approbation doit être testée directement dans le portail Power Automate
  plutôt que par courriel — documenté dans [flux.md](../flux.md).

## Décision

**Option B.** Mais un problème est apparu en écrivant les spécifications du flux : avec un seul
statut *Prorogée* utilisé à la fois pour « demandée » et pour « approuvée », le flux ne peut pas
savoir, à la lecture de `gk_statut`, s'il doit *créer* une approbation ou si une approbation a
*déjà eu lieu* — la même valeur signifiait deux choses différentes selon le moment.

**Correction** : ajout d'un statut distinct **Prorogation demandée** (`100000015`) à `gk_statut`.
Le statut *Prorogée* garde son nom mais change de sens : il signifie maintenant « prorogation
**approuvée**, en vigueur » plutôt que « demandée ». Le cycle complet :

```
En traitement → (agent·e demande) → Prorogation demandée → (flux + approbation) →
  ├─ approuvée → Prorogée (nouvelle echeance appliquee)
  └─ rejetee   → En traitement (echeance inchangee)
```

L'écran Détail affiche un message d'état (« Prorogation en attente d'approbation ») plutôt qu'un
bouton, quand `gk_statut = Prorogation demandée`. Le flux « Approbation de prorogation » (voir
[flux.md](../flux.md)) est l'unique mécanisme qui fait la transition vers *Prorogée* ou *En
traitement*, et qui met à jour `gk_dateecheance` et le journal `gk_activite`.

## Conséquences

- Nouvelle valeur de choix `gk_statut = 100000015` (Prorogation demandée), ajoutée par script
  (`scripts/Add-StatutProrogationDemandee.ps1`).
- `app/src/pages/Detail.tsx` : la fonction `approuverProrogation` et son bouton sont retirés ;
  « Demander une prorogation » fixe maintenant `gk_statut = Prorogation demandée` (plus *Prorogée*
  directement) ; nouvelle clé de traduction `detail_prorogation_en_attente`.
- Le flux doit être construit et activé pour que le cycle de prorogation se termine — sans le flux,
  une demande reste indéfiniment au statut Prorogation demandée (comportement attendu, pas un bug).
- Confirmé par script que `gk_dateecheance` est une colonne normale (`SourceType: 0`,
  `IsValidForUpdate: true`), pas une colonne formule — le flux peut la modifier sans contournement.
- Cohérent avec la Phase 4 : quand les rôles de sécurité seront en place, seul le rôle Gestionnaire
  AIPRP aura besoin d'accéder au centre d'approbations Power Automate pour cette action.
