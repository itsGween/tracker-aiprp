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

🚧 **Reste à venir — Phase 5.**

Ce document décrira, étape par étape, comment déployer la solution `gk` dans un autre environnement Power Platform : prérequis, import via `pac solution import`, configuration des variables d'environnement et des références de connexion, et création des données de démo.
