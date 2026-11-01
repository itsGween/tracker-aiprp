# 0004 — Le flux 3 est créé et modifié par code

## Statut

Acceptée

## Contexte

Les flux 1 et 2 ont été construits dans le portail. Le flux 2 a montré les limites de cette méthode :
l'ancien concepteur n'enregistrait pas toujours les champs d'approbation, ce qui causait
`AssignedToMissing`, et chaque correction devait être refaite à la main. Une définition construite
dans le portail n'est pas non plus lisible dans une revue de code.

Microsoft documente la création d'un flux cloud par l'API Web de Dataverse : un `POST` sur la table
`workflows`, avec `category = 5` et la définition dans la colonne `clientdata`.

## Options envisagées

**Option A — Construire le flux 3 dans le portail**
- ✅ Méthode déjà connue, avec validation immédiate dans le concepteur.
- ❌ Étapes manuelles, difficiles à reproduire et sujettes aux pièges du concepteur.
- ❌ La définition n'est versionnée qu'à l'export de la solution.

**Option B — Le créer par code à partir d'une définition versionnée**
- ✅ La définition est lisible et comparable dans Git, et chaque changement passe par un commit.
- ✅ La création est reproductible et le script vérifie ses prérequis avant d'écrire.
- ✅ Prépare la phase ALM : le flux reste un composant de la solution `SuiviAIPRP`.
- ❌ Format moins connu, et une erreur de définition n'apparaît parfois qu'à l'exécution.
- ❌ Le concepteur peut réinterpréter la définition si le flux y est enregistré.

## Décision

**Option B**, pour le flux 3. `src/flows/approbation-prorogation.json` est la source de vérité.
`scripts/New-FluxProrogation.ps1` crée le flux avec `-Creer` et le met à jour avec `-MettreAJour`.
Sans option, il simule. Le flux n'est jamais enregistré depuis le portail, qui sert seulement à le
lire et à consulter ses exécutions.

La définition ne contient ni identifiant d'environnement, de locataire ou de connexion, ni adresse.
Les références de connexion sont désignées par leur nom logique, et l'approbateur vient de la variable
d'environnement `gk_ApprobateurProrogation`. Le script refuse une définition qui contient une adresse
ou un GUID.

## Conséquences

- Le flux a été relu dans le portail sans enregistrement, puis testé en rejet et en approbation.
  Voir [flux.md](../flux.md).
- La correction de la branche de rejet a suivi cette méthode : modification du JSON, commit, mise à
  jour par code, nouveau test.
- `defaultValue` du paramètre de l'approbateur reste vide dans le dépôt. La valeur courante de la
  variable a bien été lue à l'exécution.
- **Risques à surveiller.** Un enregistrement dans le portail pourrait écrire l'adresse de
  l'approbateur dans `defaultValue` ou conserver la ligne vide affichée sous `Decision`. À contrôler
  avant l'export de la phase 4.
- Après une mise à jour par code, le script désactive puis réactive le flux. Il faut alors comparer
  `clientdata` au fichier du dépôt.
- Les flux 1 et 2 restent construits dans le portail à ce stade.
