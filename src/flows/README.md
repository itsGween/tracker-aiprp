# Définitions de flux

Définitions de flux cloud, au format `clientdata` de la table `workflows` de Dataverse. Elles font
foi : aucun flux n'est enregistré depuis le portail. Voir [docs/flux.md](../../docs/flux.md).

| Fichier | Flux | Mise à jour |
|---|---|---|
| `demande-recue-accuse.json` | Demande reçue - accusé de réception | `scripts/Update-Flux.ps1` |
| `rappel-quotidien-echeances.json` | Rappel quotidien des échéances | `scripts/Update-Flux.ps1` |
| `approbation-prorogation.json` | Approbation de prorogation | `scripts/New-FluxProrogation.ps1` |

Ces fichiers ne contiennent ni identifiant d'environnement ou de locataire, ni identifiant de
connexion, ni adresse. Les références de connexion sont désignées par leur nom logique, qui est un
composant de la solution et reste le même d'un environnement à l'autre. Les comptes viennent des
variables d'environnement `gk_ApprobateurProrogation` et `gk_DestinataireRappels`.
