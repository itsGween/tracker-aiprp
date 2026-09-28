# Langues officielles

🚧 **À venir — Phases 2 et 6.**

Ce document décrira :

- le fichier `app/src/i18n/traductions.ts` (68 clés FR/EN : 62 reprises de l'itération canvas + 6 ajoutées pour les valeurs de `gk_action`) ;
- le contexte React `LanguageContext` et le hook `useLanguage()` qui exposent la langue active et le bouton FR/EN ;
- la vérification qu'aucun texte n'est codé en dur dans les composants ou messages d'erreur.

Voir la décision motivant ce choix dans [ADR 0002](adr/0002-canvas-vs-code-app.md).
