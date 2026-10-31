# Définitions de flux

Définitions de flux cloud créés par code, au format `clientdata` de la table `workflows` de
Dataverse.

| Fichier | Flux | Création |
|---|---|---|
| `approbation-prorogation.json` | Approbation de prorogation | `scripts/New-FluxProrogation.ps1` |

Ces fichiers ne contiennent ni identifiant d'environnement ou de locataire, ni identifiant de
connexion, ni adresse. Les références de connexion sont désignées par leur nom logique, qui est un
composant de la solution et reste le même d'un environnement à l'autre. L'approbateur vient de la
variable d'environnement `gk_ApprobateurProrogation`.
