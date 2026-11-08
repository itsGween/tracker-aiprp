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

| Office 365 Outlook est disponible dans le nouvel environnement (connecteur standard, éditeur Microsoft) | Remplaçant possible de Mail dans le flux 1 | Décision du 8 nov. : remplacement planifié en phase 4 ou 7, par le JSON puis par code, testé dans les deux environnements |
| La code app fait partie de la solution (`CanvasApps/gk_suiviaiprpcodeappdev_465be`) | L'import de la solution gérée installe aussi l'application : pas besoin de `pa app push` | `app/power.config.json` reste celui de la source (empreinte SHA-256 identique avant et après le test) |
| À la première ouverture dans l'environnement cible, le tableau de bord reste blanc ; il s'affiche après un clic sur « Tableau de bord » | Aucun blocage, mais mauvaise première impression en démonstration | À analyser (route initiale de l'application) |
| `Import-DonneesDemo.ps1 -Importer` n'affiche pas de message de fin (les compteurs disent « à créer ») | Le résultat se vérifie à part | Compter les lignes après l'import ; message à améliorer |

### Résultat de l'import (8 novembre 2026)

| Étape | Résultat |
|---|---|
| Export de la source | Contenu identique au dossier `src/solution` (seuls les numéros de version de la plateforme changent) |
| `pac solution import` de la solution gérée, avec `deploy/settings.essai.json` | Réussi en 1 min 42. Avertissement attendu : une référence de connexion (Mail) n'a pas de connexion |
| Composants | Solution `SuiviAIPRP` 1.0.0.0 gérée ; tables `gk_demande` et `gk_activite` ; 3 variables avec leurs valeurs (`gk_EnvoiCourrielActif` = `no`) ; références Dataverse et Approbations liées, Mail et Office 365 vides ; code app présente |
| Flux | Flux 2 (rappel quotidien) et flux 3 (approbation de prorogation) activés ; flux 1 (demande reçue) en brouillon, comme prévu |
| Données de démo | 15 demandes et 39 activités importées ; aucune entrée ajoutée par un flux |
| Aller-retour | Export de l'environnement cible identique, octet pour octet, à `data/demo/demandes.json` et `activites.json` |
| Application | S'ouvre ; liste de 15 demandes ; tableau de bord : 2 + 8 + 0 + 2 + 1 + 2 = 15, « En retard (12) » |
| Flux 2 | Exécution planifiée à 8 h (heure de l'Est), à lire dans `flowrun` le lendemain. Les données importées n'ont pas d'agent assigné : l'exécution doit réussir sans créer de carton |

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
