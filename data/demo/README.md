# data/demo/

Données de démonstration, entièrement fictives, exportées par `scripts/Export-DonneesDemo.ps1` :

- `demandes.json` : les 15 demandes A-2026-01001 à A-2026-01015 ;
- `activites.json` : leur journal.

Les courriels des demandeurs utilisent le domaine réservé `example.com`. Aucun identifiant
d'environnement, ni compte réel : à l'importation, le compte connecté devient l'agent assigné et
l'auteur des activités.

Importation : `.\scripts\Import-DonneesDemo.ps1` simule, `-Importer` écrit. Les dates sont celles de
l'export ; le script de rafraîchissement des dates est prévu en phase 7.
