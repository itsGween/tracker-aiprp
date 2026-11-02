# Captures d'écran et vidéo de démo

Plan de prise de vue, dans l'ordre du parcours de démo. Les écrans hébergés par Power Platform
doivent être capturés **avant le 15 décembre 2026**, date de suspension de l'environnement de
développement. Les écrans GitHub peuvent l'être à tout moment.

Toutes les images vont dans `docs/images/`, en PNG, nommées `NN-sujet.png`.

## Règles pour chaque capture

- Fenêtre du navigateur à 100 % de zoom, largeur d'environ 1 400 px.
- Capturer **la zone de contenu seulement** (Windows + Maj + S, mode rectangle) : jamais la barre
  d'adresse, qui contient l'identifiant de l'environnement.
- Aucune adresse courriel à l'écran. Si une valeur de variable d'environnement ou un nom de compte
  complet apparaît, recadrer ou ne pas prendre la capture.
- Données à afficher : uniquement les 15 demandes de démo, sauf mention contraire.
- Ne jamais cliquer sur **Enregistrer**, **Approuver** ou **Rejeter** pendant une capture, sauf à
  l'étape prévue.

## Liste des captures

| No | Fichier | Écran | Données et contenu attendus | Qui | Quand |
|---|---|---|---|---|---|
| 01 | `01-app-tableau-de-bord.png` | Application, tableau de bord (FR) | Les tuiles par statut, encadré « En retard » | Claude (navigateur) | ✅ Fait le 2 nov. ; à refaire après le ménage des demandes de test |
| 02 | `02-app-liste-demandes.png` | Application, liste des demandes | Les 15 demandes, colonnes statut et échéance | Claude | ✅ Idem |
| 03 | `03-app-detail-retard.png`, `03b-app-journal.png` | Application, détail de A-2026-01003 | Fiche, puis journal d'activité | Claude | ✅ Idem (courriel en `exemple-fictif.ca` à remplacer) |
| 04 | `04-app-nouvelle-demande.png` | Application, Nouvelle demande remplie | Camille Lefebvre, `example.com`, Protégé A | Playwright | ✅ Fait |
| 05 | `05-app-resume-erreurs.png` | Application, résumé d'erreurs | « Veuillez remplir tous les champs obligatoires. » | Playwright | ✅ Fait |
| 06 | `06-app-tableau-de-bord-en.png` | Application, tableau de bord en anglais | Titre « ATIP Tracker » | Claude | ✅ Idem |
| 07 | `07-app-lien-evitement.png` | Application, lien d'évitement au clavier | « Aller au contenu principal » visible | Playwright | ✅ Fait |
| 08 | `08-app-prorogation-en-attente.png` | Application, détail au statut « Prorogation demandée » | Encadré « Prorogation en attente d'approbation », liste des statuts verrouillée | Claude | Pendant les tests de la phase 3 |
| 09 | `09-solution-objets.png` | Power Apps, Solutions > Suivi AIPRP > Objets | Tables, flux, variables, application | Claude (navigateur) | ✅ Fait le 2 nov. |
| 10 | `10-dataverse-colonnes.png` | Table Demande AIPRP, Colonnes | Colonnes `gk_` | Claude | ✅ Fait le 2 nov. |
| 11 | `11-dataverse-relation.png` | Table Demande AIPRP, Relations | `gk_demande` vers `gk_activite`, un-à-plusieurs | Claude | ✅ Fait le 2 nov. |
| 12 | `12-flux-liste.png` | Power Automate, flux de la solution | Les 3 flux, état « Activé » | Claude | ✅ Fait le 2 nov. |
| 13 | `13-flux1-execution.png` | Flux 1, exécution du 1er nov. à 12 h 32 | Condition fausse, branche « Faux », coches vertes | Claude | ✅ Fait le 2 nov. |
| 14 | `14-flux2-historique.png` | Flux 2, historique des exécutions | Passages de 12 h 36 (19 s) et 12 h 38 (160 ms) : preuve de l'anti-doublon | Claude | ✅ Fait le 2 nov. (cadre de l'historique seulement) |
| 15 | `15-flux3-concepteur.png` | Flux 3, concepteur, vue d'ensemble | Déclencheur, approbation, condition et ses deux branches. **Quitter sans enregistrer** | Claude | ✅ Fait le 2 nov., quitté sans enregistrer |
| 16 | `16-flux3-execution.png` | Flux 3, exécution de l'approbation | Branche « Vrai » réussie | Claude | ✅ Fait le 2 nov. |
| 17 | `17-approbation-carte.png` | Approbations, carte « Prorogation - … » ouverte | Motif et nouvelle échéance | Gween | Pendant les tests de la phase 3, avant de répondre |
| 18 | `18-roles-securite.png` | Rôles Agent AIPRP et Gestionnaire AIPRP | Matrice des privilèges | Gween | Fin de la phase 3 |
| 19 | `19-refus-serveur.png` | Message de refus du plug-in | Erreur quand l'agent de test tente « Prorogée » | Claude ou Gween | Fin de la phase 3 |
| 20 | `20-github-readme.png` | GitHub, README | Titre et diagramme d'architecture | Gween | Phase 6 |
| 21 | `21-github-actions.png` | GitHub Actions | Pipeline vert (Solution Checker) | Gween | Phase 4 |
| 22 | `22-github-adr.png` | GitHub, un ADR | Options et décision | Gween | Phase 6 |

## Vidéo de démo (2 à 3 minutes)

Enregistrement avec Clipchamp ou l'outil Capture d'écran de Windows, fenêtre du navigateur
seulement, en 1080p, sans musique. Narration en français ; sous-titres anglais ajoutés dans
Clipchamp. Préparer les onglets comme pour la démo en direct, et faire une répétition.

| Temps | Écran | Narration (résumé) |
|---|---|---|
| 0:00 – 0:15 | README GitHub, diagramme | Le besoin : suivre les demandes AIPRP et le délai légal de 30 jours, sur Power Platform, données fictives |
| 0:15 – 0:40 | Tableau de bord, encadré en retard | Vue d'ensemble, retards et échéances à 5 jours calculés à partir de la date du jour |
| 0:40 – 1:05 | Nouvelle demande, puis sa fiche | Création, échéance et numéro automatiques, première entrée au journal |
| 1:05 – 1:25 | Flux 1, dernière exécution | Le flux s'est déclenché ; variable d'environnement, pas de courriel en développement |
| 1:25 – 2:00 | Demande de prorogation, carte d'approbation, résultat | Séparation des tâches : l'agent demande, le gestionnaire approuve, le flux applique |
| 2:00 – 2:20 | Refus du serveur (phase 3) | Le plug-in refuse un changement interdit, même par l'API |
| 2:20 – 2:40 | Bascule FR/EN, clavier | Bilinguisme et accessibilité, tests axe-core |
| 2:40 – 3:00 | GitHub : solution dépaquetée, Actions | ALM : tout est versionné et vérifié automatiquement |

La séquence 1:25 – 2:20 dépend de la phase 3 : enregistrer la vidéo à la fin de la phase 3, avant le
15 décembre.

### Où déposer la vidéo

- **Pas dans le dépôt** : un fichier vidéo alourdirait l'historique Git pour toujours.
- **YouTube, en « non répertoriée »** : lien stable, lecteur intégrable dans le portfolio
  (`youtube-nocookie.com`) et dans LinkedIn.
- **README** : une image cliquable (la capture 01) qui mène à la vidéo, plutôt qu'un lecteur intégré.
  GitHub limite aussi la taille des vidéos téléversées.
- **Portfolio** : lecteur YouTube intégré sur la page d'étude de cas.
- Garder le fichier original dans OneDrive.
