# Archive

Trace des itérations abandonnées du projet — gardées pour pouvoir expliquer les changements de
direction en entrevue, pas parce qu'elles sont encore utilisées.

## `powerfx-canvas/`

La Phase 2 a commencé avec une **application canvas Power Apps** (Power Fx, Power Apps Studio).
L'écran 1 (Tableau de bord) avait été entièrement spécifié et la formule `App.OnStart` (table de
traductions FR/EN, 62 clés) avait été testée avec succès dans Studio.

**Changement de direction** : le projet est passé à une **Power Apps code app** (React + TypeScript
+ Vite), pour utiliser la stack principale de l'auteure et se rapprocher d'un contexte de
développement IT-02 réel. Voir [ADR 0002](../adr/0002-canvas-vs-code-app.md) pour le contexte
complet, les options envisagées et les conséquences de ce changement.

Le contenu de `powerfx-canvas/` est une copie figée de `powerfx/` au moment du changement de
direction : la formule `App.OnStart` en syntaxe française et les notes sur les séparateurs Power Fx
en locale française. Les 62 clés de traduction ont été réutilisées telles quelles dans le fichier
`app/src/i18n/traductions.ts` de la code app.

L'application canvas elle-même reste présente dans l'environnement Dataverse pour l'instant ; elle
sera supprimée lors du ménage final (Phase 7).
