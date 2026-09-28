# scripts/

Scripts PowerShell du projet :

- `Connect-Dataverse.ps1` : authentification vers l'API Web Dataverse (MSAL, mise en cache locale du jeton — voir `.env.example`).
- `New-DataverseSchema.ps1` : création du schéma Dataverse (tables `gk_demande`/`gk_activite`, colonnes, relations). Idempotent.
- `New-DemoData.ps1` : génération des 15 demandes fictives et de leur journal d'activité.
- `New-EnvironmentVariable.ps1` : création de la variable d'environnement `gk_EnvoiCourrielActif` (utilisée par le flux « Demande reçue », voir [docs/flux.md](../docs/flux.md)).

Aucun script de ce dossier ne doit contenir de secret, d'identifiant de locataire ni de courriel réel — voir `.gitignore` et `.env.example`.
