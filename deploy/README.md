# deploy/

`settings.template.json` est le fichier de paramètres de déploiement de la solution `SuiviAIPRP`,
produit par `pac solution create-settings`. Il est versionné **sans valeurs**.

Pour un déploiement, copier le modèle (par exemple en `settings.dev.json`, ignoré par Git), puis
remplir :

| Paramètre | Valeur attendue |
|---|---|
| `gk_ApprobateurProrogation` | Compte (UPN) du gestionnaire qui approuve les prorogations |
| `gk_DestinataireRappels` | Compte (UPN) qui reçoit les rappels d'échéance |
| `gk_EnvoiCourrielActif` | `yes` ou `no` (`no` sans boîte aux lettres) |
| `ConnectionId` de chaque référence | Identifiant d'une connexion créée dans l'environnement cible |

Importation :

```powershell
pac solution import --path out\solution\SuiviAIPRP_managed.zip --settings-file deploy\settings.dev.json
```

Les références `gk_sharedoffice365_*` viennent d'essais anciens et ne sont utilisées par aucun flux.
Leur retrait est prévu au ménage de la phase 7.
