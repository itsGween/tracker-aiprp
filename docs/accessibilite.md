# Accessibilité

## Tests automatisés (Playwright + axe-core)

`app/tests/` — `npm run test:e2e` dans `app/`. 12 tests, tous verts :

- **Aucune violation axe-core** (règles WCAG 2.1 A/AA) sur les 3 écrans testables sans hôte Power
  Apps : Tableau de bord (état de chargement), Liste des demandes (état de chargement), Nouvelle
  demande (formulaire complet, y compris l'état d'erreur de validation).
- **Lien d'évitement** : premier élément atteignable au clavier (`Tab`), visible au focus.
- **Bascule de langue** : traduit l'interface, met à jour `<html lang>`, conserve un nom accessible
  correct sur le bouton avant/après bascule.
- **Navigation principale** : atteignable et activable entièrement au clavier.
- **Nouvelle demande** : étiquettes présentes sur tous les champs, validation, résumé d'erreurs
  accessible, bouton Annuler.

Voir [app/tests/README.md](../app/tests/README.md) pour la portée exacte et sa limite assumée :
les écrans branchés sur Dataverse (tableau de bord rempli, liste remplie, détail d'une demande) ne
sont pas couverts par ces tests automatisés — l'hôte Power Apps (authentification Microsoft Entra)
n'est pas disponible dans l'environnement de test. Ces écrans ont été **vérifiés manuellement** dans
le navigateur (`pa app run` + Local Play) pendant la Phase 2, incluant un cycle complet de création
d'une demande.

## Un vrai bug trouvé et corrigé grâce aux tests

Le premier passage du test de bascule de langue a échoué — pas à cause du test, mais d'un vrai
problème : le bouton de langue (`GcdsButton`) ne mettait pas à jour son `aria-label` interne quand la
prop React changeait après le rendu initial. Après avoir basculé vers l'anglais, un·e utilisateur·rice
de lecteur d'écran aurait toujours entendu « Passer en anglais » au lieu de « Switch to French ».

**Correctif** : `key={langue}` sur le composant (`app/src/components/Layout.tsx`), qui force React à
démonter et remonter le composant web à chaque changement de langue plutôt que de compter sur sa
réactivité interne aux changements d'attributs. Un bon exemple concret de pourquoi les tests
d'accessibilité automatisés valent la peine, même sur une petite app — bon point à raconter en
entrevue.

## Liste de contrôle WCAG 2.1 AA

🚧 **À venir — Phase 6** : liste de contrôle complète par critère de succès, tests manuels
(lecteur d'écran NVDA/VoiceOver, contraste), captures d'écran.

Voir la décision motivant le passage à une code app (et donc à Playwright + axe-core plutôt qu'une
vérification manuelle des `AccessibleLabel`) dans [ADR 0002](adr/0002-canvas-vs-code-app.md).
