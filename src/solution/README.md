# src/solution/

Solution Power Platform `SuiviAIPRP` **dépaquetée** avec `pac solution unpack --packagetype Both` :
tables, formulaires, vues, variables d'environnement, références de connexion, flux et package de
la code app, sous forme de fichiers texte versionnables.

## Mettre à jour

```powershell
pac solution export --name SuiviAIPRP --path out\solution\SuiviAIPRP.zip --overwrite
pac solution export --name SuiviAIPRP --path out\solution\SuiviAIPRP_managed.zip --managed --overwrite
pac solution unpack --zipfile out\solution\SuiviAIPRP.zip --folder src\solution --packagetype Both --allowDelete false
```

## Reconstruire les fichiers .zip

```powershell
pac solution pack --zipfile out\solution\SuiviAIPRP.zip --folder src\solution --packagetype Both
```

La commande produit `SuiviAIPRP.zip` (non gérée) et `SuiviAIPRP_managed.zip` (gérée). Les binaires
(`.zip`, `.msapp`) ne sont pas suivis par Git.

## Ce que le dossier ne contient pas

- Les valeurs des variables d'environnement et les identifiants des connexions : ils viennent du
  fichier de paramètres de déploiement (`deploy/settings.template.json`).
- Les données : voir `data/demo/` et `scripts/Import-DonneesDemo.ps1`.

Les flux sont aussi dans `src/flows/`, qui reste la source des mises à jour par code. Après une
mise à jour, réexporter la solution pour garder les deux copies identiques.
