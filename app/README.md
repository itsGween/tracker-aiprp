# Suivi AIPRP — code app

Interface React + TypeScript de Suivi AIPRP, hébergée par Power Apps et branchée sur Dataverse.
Pour la vue d'ensemble du projet, voir le [README principal](../README.md).

## Prérequis

- Node.js 22 ou plus récent
- Power Apps CLI (`pa`) 1.0.2, installé avec les dépendances du projet
- Un environnement Power Platform contenant la solution `SuiviAIPRP`

## Configuration locale

`power.config.json` et le dossier `.power/` contiennent des identifiants d'environnement. Ils sont
générés localement et ne sont jamais versionnés. `power.config.example.json` sert de gabarit.

## Commandes

| Commande | Rôle |
|---|---|
| `npm run dev` | Serveur de développement Vite |
| `npm run lint` | Analyse ESLint |
| `npm run build` | Vérification TypeScript et build de production |
| `npm test` | Tests unitaires Vitest, en fuseau `America/Toronto` |
| `npm run test:e2e` | Tests Playwright + axe-core (voir [tests/README.md](tests/README.md)) |
| `pa app run` | Exécution locale dans l'hôte Power Apps, avec accès à Dataverse |
| `pa app push` | Publication dans l'environnement |

## Structure

| Dossier | Contenu |
|---|---|
| `src/pages/` | Les 4 écrans : tableau de bord, liste, détail, nouvelle demande |
| `src/components/` | Mise en page commune |
| `src/context/` | Langue courante (FR/EN) |
| `src/i18n/` | Traductions de l'interface |
| `src/utils/` | Dates et auteur des activités |
| `src/generated/` | Modèles et services générés par `pa` — ne pas modifier à la main |
| `tests/` | Tests de bout en bout et d'accessibilité |

## Conventions de dates

Les colonnes « date seule » de Dataverse représentent un jour du calendrier, sans fuseau : elles
sont traitées comme du texte `AAAA-MM-JJ`, jamais avec `new Date("AAAA-MM-JJ")`, qui les lirait en
UTC et afficherait la veille au Canada. Seul `gk_date` (journal d'activité) est un horodatage,
converti en heure locale. Tout passe par `src/utils/dates.ts`.
