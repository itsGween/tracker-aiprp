# Installation

## Configurer la code app localement

`app/power.config.json` contient l'ID de l'environnement Dataverse et n'est **jamais commis** (voir
`.gitignore`). Après avoir cloné le dépôt :

```powershell
cd app
cp power.config.example.json power.config.json
# Remplacer environmentId par le GUID de ton propre environnement
npm install
pa auth login
pa app run
```

Le dossier `app/.power/` (schémas générés par `pa app add data-source`) est aussi ignoré par Git ; il
se régénère automatiquement.

🚧 **Reste à venir — étape C5 (novembre 2026).**

Ce document décrira, étape par étape, comment déployer la solution `gk` dans un autre environnement Power Platform : prérequis, import via `pac solution import`, configuration des variables d'environnement et des références de connexion, et création des données de démo.

## Constats du test de redéploiement (novembre 2026)

Le test de l'étape C réinstalle le projet dans un environnement d'essai neuf (« Suivi AIPRP -
essai », Canada, français), créé le 8 novembre 2026. Ce qu'il a appris jusqu'ici :

| Constat | Conséquence | Solution retenue |
|---|---|---|
| `pac admin create --region canada` échoue avec `macroRegion 'canada' is not valid` (PAC CLI 2.12.2, issue microsoft/powerplatform-vscode#1678, corrigée en 2.15) | L'environnement ne peut pas être créé en ligne de commande avec cette version | Création dans le centre d'administration Power Platform |
| Une licence d'essai Power Apps est nécessaire pour créer un environnement d'essai : le Developer Plan ne suffit pas | Une licence « PowerApps Trial » de 30 jours, prolongeable jusqu'à 90 jours | Prolonger la licence et l'environnement à temps |
| « Activer les code apps » est désactivé par défaut et n'est pas une colonne de la table `organization` (`pac env update-settings` ne le change pas) | Une code app ne s'exécute pas tant que le réglage est désactivé | Bascule dans le centre d'administration (Paramètres > Produit > Fonctionnalités) ou réglage `powerApps_AllowCodeApps` de l'API Power Platform |
| Le connecteur **Mail** (`shared_sendmail`) n'apparaît ni dans Power Apps ni dans Power Automate pour le nouvel environnement. Sa page Microsoft Learn indique qu'il est « restreint pour les nouveaux locataires et les nouvelles régions » et recommande Office 365 Outlook, Gmail ou SendGrid | Impossible de créer une connexion Mail ; la référence `gk_sharedsendmail_577cd`, utilisée seulement par la branche « Si oui » du flux 1 (Demande reçue), reste sans connexion | Voir ci-dessous |

### Référence de connexion Mail sans connexion

Le flux 1 n'envoie un courriel que si `gk_EnvoiCourrielActif` vaut `yes`. La valeur est `no` dans
les environnements du projet, qui n'ont pas de boîte aux lettres. Mais Power Automate refuse
d'activer un flux dont une référence de connexion n'est liée à aucune connexion, même si l'action
concernée ne s'exécute jamais. Les options étudiées :

| Option | Effet | Limite |
|---|---|---|
| Créer la connexion pendant l'importation | Le connecteur est absent du catalogue de l'environnement : l'assistant d'importation ne peut pas la créer non plus | Ne règle rien |
| Importer avec la référence Mail vide | La solution s'importe ; les flux 2 et 3 s'activent ; le flux 1 reste désactivé | Le flux 1 ne peut pas être testé dans l'environnement cible |
| Remplacer Mail par Office 365 Outlook dans le flux 1 (modification de `src/flows/demande-recue-accuse.json`, puis mise à jour par code) | Connecteur recommandé par Microsoft et disponible partout | Envoyer demande une boîte aux lettres Exchange ; à vérifier : la création d'une connexion sans boîte aux lettres, qui suffirait tant que la variable vaut `no` |
| Retirer l'envoi du flux 1 et le confier à un flux séparé, activé seulement là où une boîte aux lettres existe | Le flux 1 n'a plus besoin de connecteur de courriel | Un flux de plus à maintenir |

Les valeurs des références de connexion et des variables sont dans `deploy/settings.essai.json`,
ignoré par Git (voir `deploy/README.md`).
