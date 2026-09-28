// Fonctions utilitaires de date, utilisees a la place d'une colonne formule
// Dataverse (impossible pour une valeur qui depend de la date du jour).
// Voir docs/modele-donnees.md#pourquoi-lecheance-nest-pas-une-colonne-formule

export function joursRestants(dateEcheance: string): number {
  const echeance = new Date(dateEcheance);
  const aujourdhui = new Date();
  echeance.setHours(0, 0, 0, 0);
  aujourdhui.setHours(0, 0, 0, 0);
  const msParJour = 1000 * 60 * 60 * 24;
  return Math.round((echeance.getTime() - aujourdhui.getTime()) / msParJour);
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
  const d = new Date(date);
  return d.toLocaleDateString(langue === "fr" ? "fr-CA" : "en-CA", {
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  });
}

export function dansNJours(n: number): string {
  const d = new Date();
  d.setDate(d.getDate() + n);
  return d.toISOString().split("T")[0];
}

export function aujourdhuiISO(): string {
  return new Date().toISOString().split("T")[0];
}
