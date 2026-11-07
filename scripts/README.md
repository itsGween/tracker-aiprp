# scripts/

Scripts PowerShell du projet :

- `Connect-Dataverse.ps1` : authentification vers l'API Web Dataverse (MSAL, mise en cache locale du jeton — voir `.env.example`).
- `New-DataverseSchema.ps1` : création du schéma Dataverse (tables `gk_demande`/`gk_activite`, colonnes, relations). Idempotent.
- `New-DemoData.ps1` : génération des 15 demandes fictives et de leur journal d'activité.
- `Repair-DonneesDemo.ps1` : correction ponctuelle des données de démo (simulation par défaut, `-Appliquer` pour écrire).
- `New-EnvironmentVariable.ps1` : création de la variable d'environnement `gk_EnvoiCourrielActif` (utilisée par le flux « Demande reçue », voir [docs/flux.md](../docs/flux.md)).
- `Export-DonneesDemo.ps1` / `Import-DonneesDemo.ps1` : sauvegarde des 15 demandes de démo et de leur journal dans `data/demo/`, puis réimportation dans un autre environnement (simulation par défaut, `-Importer` pour écrire).

## Viser un autre environnement

Par défaut, les scripts lisent `scripts/.env`. Pour un autre environnement (par exemple l'environnement d'essai du test de redéploiement), créer un second fichier à partir de `.env.example`, par exemple `scripts/.env.essai` (ignoré par Git), puis le passer avec `-EnvFile`. Pour écrire, `Import-DonneesDemo.ps1` exige aussi `-Cible`, le début du nom d'hôte de l'environnement visé : si l'environnement connecté ne correspond pas, le script s'arrête sans rien faire.

```powershell
.\scripts\Import-DonneesDemo.ps1 -EnvFile scripts\.env.essai                                   # simulation
.\scripts\Import-DonneesDemo.ps1 -EnvFile scripts\.env.essai -Cible suiviaiprp-essai -Importer
```

Le jeton de connexion est mis en cache par environnement, dans `%TEMP%` : un jeton d'un environnement n'est jamais réutilisé pour un autre.

Aucun script de ce dossier ne doit contenir de secret, d'identifiant de locataire ni de courriel réel — voir `.gitignore` et `.env.example`.
