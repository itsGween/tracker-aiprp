# powerfx/

Contient, un sous-dossier par écran, les formules Power Fx commentées et les fichiers `.pa.yaml` prêts à être collés dans Power Apps Studio :

- `01-tableau-de-bord/`
- `02-liste-des-demandes/`
- `03-detail-et-traitement/`
- `04-nouvelle-demande/`

## ⚠️ Séparateurs : locale française

Power Apps Studio de Gween est en français. Power Fx adapte ses séparateurs selon la locale
(le français utilise la virgule comme séparateur décimal, donc elle n'est pas disponible comme
séparateur de fonction) :

| Rôle | Locale anglaise (EN-US) | Locale française (FR) |
|---|---|---|
| Séparateur d'arguments dans une fonction, ex. `Set(a, b)` | `,` | `;` |
| Séparateur de champs dans un enregistrement, ex. `{Cle: x, FR: y}` | `,` | `;` |
| Séparateur d'instructions chaînées (plusieurs formules à la suite, ex. `App.OnStart`) | `;` | `;;` |
| Séparateur décimal, ex. `0.5` | `.` | `,` |

Toutes les formules de ce dépôt sont écrites avec la syntaxe **française** (`;` et `;;`) pour être
collées directement dans Studio sans modification. Si tu changes la langue de Studio en anglais un
jour, il faudra les adapter (`;` → `,`, `;;` → `;`).
