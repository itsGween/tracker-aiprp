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
| 14 | `14-flux2-historique.png` | Flux 2, historique des exécutions | Passages de 12 h 36 (19 s) et 12 h 38 (160 ms) : preuve de l'anti-doublon | Claude | ✅ Fait le 2 nov. (cadre de l'historique seulement, refaite sans pointeur) |
| 15 | `15-flux3-concepteur.png` | Flux 3, concepteur, vue d'ensemble | Déclencheur, approbation, condition et ses deux branches. **Quitter sans enregistrer** | Claude | ✅ Fait le 2 nov., quitté sans enregistrer |
| 16 | `16-flux3-execution.png` | Flux 3, exécution de l'approbation | Branche « Vrai » réussie | Claude | ✅ Fait le 2 nov. |
| 17 | `17-approbation-carte.png` | Approbations, carte « Prorogation - … » ouverte | Motif et nouvelle échéance | Gween | Pendant les tests de la phase 3, avant de répondre |
| 18 | `18-roles-securite.png` | Rôles Agent AIPRP et Gestionnaire AIPRP | Matrice des privilèges | Gween | Fin de la phase 3 |
| 19 | `19-refus-serveur.png` | Message de refus du plug-in | Erreur quand l'agent de test tente « Prorogée » | Claude ou Gween | Fin de la phase 3 |
| 20 | `20-github-readme.png` | GitHub, README | Titre et diagramme d'architecture | Gween | Phase 6 |
| 21 | `21-github-actions.png` | GitHub Actions | Pipeline vert (Solution Checker) | Gween | Phase 4 |
| 22 | `22-github-adr.png` | GitHub, un ADR | Options et décision | Gween | Phase 6 |

## Captures à refaire après le ménage des données

Les compteurs actuels incluent les 2 demandes de test (A-2026-01021 et A-2026-01022), et la
fiche de A-2026-01003 affiche un courriel en `exemple-fictif.ca`. Après le ménage (suppression de
A-2026-01022, puis de A-2026-01021 à la fin des tests de la phase 3, avec l'accord de Gween, courriels passés en `example.com`), refaire **01, 02, 03,
03b, 06 et 14** (dans l'application publiée, et dans Power Automate pour la 14), le 5 décembre au plus tard. Contrôle : la somme des tuiles du
tableau de bord vaut 15.

## Captures de la phase 3 (08, 17, 18, 19)

Elles se prennent pendant le test de séparation des tâches, dans cet ordre, sur **A-2026-01021
seulement**. Préparer deux fenêtres : une fenêtre InPrivate connectée avec `agent.test` (l'agent), la
fenêtre normale avec le compte de Gween (le gestionnaire).

1. **08 — Prorogation en attente** (fenêtre `agent.test`, application publiée). Ouvrir A-2026-01021 ;
   si elle est à « Prorogée », la remettre à « En traitement ». Remplir « Demander une prorogation »
   avec un motif fictif et une nouvelle échéance postérieure à l'échéance actuelle, puis soumettre.
   Capturer la fiche : encadré « Prorogation en attente d'approbation », liste des statuts
   verrouillée. Recadrer sous la barre Power Apps et exclure le champ courriel s'il est rempli.
2. **17 — Carte d'approbation** (fenêtre de Gween). Power Automate > Approbations > Reçues, ouvrir la
   carte « Prorogation - A-2026-01021 ». Attendre qu'elle apparaisse (jusqu'à quelques minutes).
   Capturer le motif et la nouvelle échéance **avant de répondre**. Ne pas montrer les adresses du
   demandeur ni de l'approbateur : recadrer sur le corps de la carte. Répondre ensuite, comme prévu
   par le test.
3. **18 — Rôles de sécurité** (fenêtre de Gween, à la fin de la phase 3). Centre d'administration
   Power Platform > environnement > Paramètres > Utilisateurs + autorisations > Rôles de sécurité >
   « Agent AIPRP », filtrer les tables sur `gk_`, capturer la matrice des privilèges ; même chose pour
   « Gestionnaire AIPRP ». Lecture seule : ne rien modifier, ne pas cliquer sur Enregistrer. Une
   image par rôle si une seule ne suffit pas (`18-roles-securite.png`, `18b-roles-securite.png`).
4. **19 — Refus du serveur** (fin de la phase 3). Avec `agent.test`, tenter de passer A-2026-01021 à
   « Prorogée » par l'API Web (script de test de la phase 3), puis capturer le message d'erreur du
   plug-in dans le terminal. Avant la capture : vérifier qu'aucune URL d'organisation, aucun jeton et
   aucun courriel n'apparaissent dans la sortie.

Les captures 20 et 22 (GitHub) se prennent en phase 6, une fois le README définitif ; la 21, quand le
pipeline de la phase 4 est vert. Elles ne dépendent pas de l'environnement.

## Démonstration de secours (sans son)

`demo-suivi-aiprp-2026-11-02.gif` (3 Mo, 28 images), enregistrée le 2 novembre dans l'application
publiée depuis Chrome : tableau de bord, liste, recherche « Fontaine », bascule en anglais puis
retour en français, formulaire Nouvelle demande. Aucune fiche détail (elle affiche un courriel),
aucune donnée modifiée. Le fichier n'est **pas** dans le dépôt : il est conservé dans OneDrive.

## Vidéo de démo (2 à 3 minutes)

Enregistrement avec Clipchamp ou l'outil Capture d'écran de Windows, fenêtre du navigateur
seulement, en 1080p, sans musique. Narration en français ; sous-titres anglais ajoutés dans
Clipchamp. À enregistrer **à la fin de la phase 3, avant le 15 décembre**, après le ménage des
données.

### Préparation

- Données : ménage fait, 15 demandes de démo, dates rafraîchies. A-2026-01021 à « En traitement »
  pour la séquence de prorogation (ou la demande prévue par le test de la phase 3).
- Fenêtres : Chrome avec le compte de Gween (gestionnaire) et une fenêtre InPrivate avec
  `agent.test` (agent). Zoom à 100 %, barre de favoris masquée, notifications Windows coupées.
- Onglets ouverts dans l'ordre : README GitHub, application (fenêtre agent), Power Automate >
  historique du flux 1, Approbations (fenêtre gestionnaire), terminal prêt pour le test de refus,
  GitHub > `src/solution` et Actions.
- Jamais à l'écran : barre d'adresse (la masquer au montage si besoin), courriels, panneau
  « Références de connexion », valeurs des variables d'environnement.
- Faire une répétition complète sans enregistrer.

### Scénario final

| Temps | Écran | Action | Narration (résumé) |
|---|---|---|---|
| 0:00 – 0:15 | README GitHub, diagramme | Défiler jusqu'au diagramme | Le besoin : suivre les demandes AIPRP et le délai légal de 30 jours, sur Power Platform, données fictives |
| 0:15 – 0:35 | Tableau de bord (agent) | Montrer les tuiles et l'encadré « En retard » | Retards et échéances à 5 jours, calculés à partir de la date du jour |
| 0:35 – 1:00 | Nouvelle demande, puis sa fiche | Créer une demande fictive en `example.com`, ouvrir sa fiche | Échéance et numéro automatiques, première entrée au journal |
| 1:00 – 1:15 | Flux 1, dernière exécution | Ouvrir l'exécution qui vient d'avoir lieu | Le flux s'est déclenché ; variable d'environnement, pas de courriel en développement |
| 1:15 – 1:35 | Fiche de la demande de test (agent) | Demander une prorogation, motif et nouvelle échéance | L'agent demande ; la liste des statuts se verrouille |
| 1:35 – 1:55 | Approbations (gestionnaire) | Ouvrir la carte, approuver | Un autre compte, le gestionnaire, décide |
| 1:55 – 2:05 | Fiche de la demande (agent) | Actualiser : « Prorogée », nouvelle échéance, journal | Le flux applique la décision et la trace |
| 2:05 – 2:25 | Terminal | Lancer la tentative de l'agent par l'API | Le plug-in refuse le changement, même hors de l'application |
| 2:25 – 2:40 | Application | Bascule FR/EN, Tab pour le lien d'évitement | Bilinguisme et accessibilité, tests axe-core |
| 2:40 – 3:00 | GitHub : `src/solution`, Actions | Montrer la solution dépaquetée et le pipeline | ALM : tout est versionné et vérifié automatiquement |

Au montage : couper les attentes (apparition de la carte d'approbation, exécution du flux), ajouter
les sous-titres anglais, exporter en 1080p.

### Où déposer la vidéo

- **Pas dans le dépôt** : un fichier vidéo alourdirait l'historique Git pour toujours.
- **YouTube, en « non répertoriée »** : lien stable, lecteur intégrable dans le portfolio
  (`youtube-nocookie.com`) et dans LinkedIn.
- **README** : une image cliquable (la capture 01) qui mène à la vidéo, plutôt qu'un lecteur intégré.
  GitHub limite aussi la taille des vidéos téléversées.
- **Portfolio** : lecteur YouTube intégré sur la page d'étude de cas.
- Garder le fichier original dans OneDrive.
