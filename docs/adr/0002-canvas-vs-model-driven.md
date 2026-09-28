# 0002 — Application canvas plutôt que modèle-pilotée

## Statut

Acceptée

## Contexte

Une fois [Dataverse choisi comme source de données](0001-dataverse-vs-sharepoint.md), Power Apps propose deux types d'application pour construire l'interface : une application modèle-pilotée (formulaires et vues générés à partir du schéma des tables) ou une application canvas (mise en page et logique définies écran par écran avec Power Fx).

L'application vise quatre écrans précis (tableau de bord, liste, détail/traitement, nouvelle demande), doit être entièrement bilingue FR/EN sans texte codé en dur, et doit respecter WCAG 2.1 AA avec des `AccessibleLabel` explicites sur chaque contrôle. C'est aussi une pièce de portfolio destinée à démontrer une maîtrise pratique de Power Fx en entrevue.

## Options envisagées

**Option A — Application modèle-pilotée**
- ✅ Formulaires, vues et navigation générés automatiquement à partir du schéma Dataverse ; développement plus rapide.
- ✅ Cohérence native avec les rôles de sécurité Dataverse (formulaires filtrés par rôle sans configuration supplémentaire).
- ❌ Peu de contrôle fin sur la mise en page, le contraste et l'ordre de tabulation — la personnalisation pour WCAG 2.1 AA est plus limitée.
- ❌ Le bilinguisme dynamique (bouton FR/EN, aucun texte codé en dur) est plus difficile à implémenter que dans un canvas, où chaque étiquette est une formule.
- ❌ Démontre moins directement la compétence Power Fx recherchée pour les postes visés.

**Option B — Application canvas**
- ✅ Contrôle pixel par pixel de la mise en page, utile pour un tableau de bord avec compteurs et indicateurs visuels.
- ✅ Bilinguisme simple à implémenter : une collection ou table de traductions, chaque étiquette liée par formule (`Traductions[...].fr` / `.en`), aucun texte codé en dur.
- ✅ `AccessibleLabel`, `TabIndex` et contraste contrôlables explicitement sur chaque contrôle, alignés avec la liste de contrôle WCAG 2.1 AA visée.
- ✅ Chaque écran s'exprime en formules Power Fx lisibles et versionnables (`.pa.yaml`), ce qui correspond directement aux compétences à démontrer en entrevue.
- ❌ Plus de travail manuel qu'un modèle-pilotée : pas de formulaires ni de vues générés automatiquement.
- ❌ Le contrôle d'accès par rôle doit être vérifié explicitement dans les formules (`User().Email`, appartenance au rôle) plutôt qu'hérité automatiquement de la sécurité Dataverse au niveau du formulaire.

## Décision

**Application canvas.** Le nombre limité d'écrans (quatre), l'exigence de bilinguisme sans texte codé en dur, la cible d'accessibilité WCAG 2.1 AA et l'objectif de démonstration de compétences Power Fx en entrevue favorisent le contrôle fin qu'offre le canvas, malgré le développement manuel plus long.

## Conséquences

- Chaque écran doit gérer explicitement l'affichage bilingue via une table de traductions — voir [langues-officielles.md](../langues-officielles.md).
- L'accessibilité (labels, ordre de tabulation, contraste) est une responsabilité du développement de chaque écran, pas héritée automatiquement — voir [accessibilite.md](../accessibilite.md).
- Les rôles de sécurité Dataverse limitent l'accès aux données, mais l'application canvas doit aussi adapter l'interface selon le rôle de l'utilisateur·rice connecté·e (ex. : masquer l'approbation de prorogation pour un Agent AIPRP).
