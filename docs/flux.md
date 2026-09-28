# Flux Power Automate

🚧 **À venir — Phase 3.**

Ce document décrira, pour chacun des trois flux, le déclencheur, les étapes et la gestion d'erreurs :

1. **Demande reçue** — ajoute une activité « Demande reçue » et envoie un accusé de réception à la création d'une demande.
2. **Rappels d'échéance** — flux planifié quotidien qui avertit les agent·es des demandes à 5 jours ou moins de l'échéance, ou en retard.
3. **Prorogation** — approbation par le ou la gestionnaire ; si approuvée, met à jour l'échéance, le statut et le journal.

⚠️ **Limite connue :** le tenant de développement n'a pas de licence Exchange/Outlook. Une alternative fonctionnant sans boîte aux lettres (ex. : notifications via Teams, ou journal in-app avec approbation via colonne de statut dans Dataverse plutôt que via le connecteur Approbations) sera proposée et documentée ici avant l'implémentation.

Voir le survol de ces flux dans [architecture.md](architecture.md#2-diagramme-de-composants).
