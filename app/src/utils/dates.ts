// Fonctions utilitaires de date, utilisees a la place d'une colonne formule
// Dataverse (impossible pour une valeur qui depend de la date du jour).
// Voir docs/modele-donnees.md#pourquoi-lecheance-nest-pas-une-colonne-formule
//
// Deux sortes de valeurs a ne pas confondre :
// - colonnes "date seule" (gk_datereception, gk_dateecheance,
//   gk_nouvelleecheanceprorogation) : un jour du calendrier, sans fuseau.
//   new Date("2026-10-06") le lirait comme minuit UTC, soit la veille a Ottawa.
//   On calcule donc sur la partie AAAA-MM-JJ, toujours en UTC.
// - gk_date (journal) : un vrai horodatage UTC, converti en heure locale.

const MS_PAR_JOUR = 1000 * 60 * 60 * 24;

function jourEnMs(date: string): number {
  const [annee, mois, jour] = date.slice(0, 10).split("-").map(Number);
  return Date.UTC(annee, mois - 1, jour);
}

function localeDe(langue: "fr" | "en"): string {
  return langue === "fr" ? "fr-CA" : "en-CA";
}

export function joursRestants(dateEcheance: string): number {
  return Math.round((jourEnMs(dateEcheance) - jourEnMs(aujourdhuiISO())) / MS_PAR_JOUR);
}

export function estEnRetard(dateEcheance: string): boolean {
  return joursRestants(dateEcheance) < 0;
}

export function estBientotEcheance(dateEcheance: string, seuilJours = 5): boolean {
  const jours = joursRestants(dateEcheance);
  return jours >= 0 && jours <= seuilJours;
}

export function formaterDate(date: string | undefined, langue: "fr" | "en"): string {
  if (!date) return "";
  return new Date(jourEnMs(date)).toLocaleDateString(localeDe(langue), {
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
    timeZone: "UTC",
  });
}

export function formaterDateHeure(date: string | undefined, langue: "fr" | "en"): string {
  if (!date) return "";
  return new Date(date).toLocaleString(localeDe(langue), {
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
    hour: "2-digit",
    minute: "2-digit",
    hourCycle: "h23",
  });
}

export function ajouterJours(date: string, n: number): string {
  return new Date(jourEnMs(date) + n * MS_PAR_JOUR).toISOString().slice(0, 10);
}

export function dansNJours(n: number): string {
  return ajouterJours(aujourdhuiISO(), n);
}

export function aujourdhuiISO(): string {
  const d = new Date();
  const mois = String(d.getMonth() + 1).padStart(2, "0");
  const jour = String(d.getDate()).padStart(2, "0");
  return `${d.getFullYear()}-${mois}-${jour}`;
}
