import { afterEach, describe, expect, it, vi } from "vitest";
import {
  ajouterJours,
  aujourdhuiISO,
  dansNJours,
  estBientotEcheance,
  estEnRetard,
  formaterDate,
  formaterDateHeure,
  joursRestants,
} from "./dates";

// Fixe l'heure courante, exprimee avec le decalage d'Ottawa pour rester lisible.
function fixerMaintenant(dateHeure: string) {
  vi.useFakeTimers();
  vi.setSystemTime(new Date(dateHeure));
}

afterEach(() => {
  vi.useRealTimers();
});

describe("environnement de test", () => {
  it("s'execute bien en fuseau America/Toronto", () => {
    expect(Intl.DateTimeFormat().resolvedOptions().timeZone).toBe("America/Toronto");
  });
});

describe("formaterDate (colonnes date seule)", () => {
  it("affiche le jour stocke dans Dataverse, sans recul d'un jour", () => {
    expect(formaterDate("2026-10-06", "fr")).toBe("2026-10-06");
    expect(formaterDate("2026-10-06", "en")).toBe("2026-10-06");
  });

  it("garde le meme jour si la date arrive avec une heure UTC", () => {
    expect(formaterDate("2026-10-06T00:00:00Z", "fr")).toBe("2026-10-06");
  });

  it("renvoie une chaine vide sans date", () => {
    expect(formaterDate(undefined, "fr")).toBe("");
  });
});

describe("formaterDateHeure (horodatage du journal)", () => {
  it("convertit l'horodatage UTC en heure locale", () => {
    expect(formaterDateHeure("2026-10-06T18:30:00Z", "fr")).toBe("2026-10-06 14 h 30");
    expect(formaterDateHeure("2026-10-06T18:30:00Z", "en")).toBe("2026-10-06, 14:30");
  });

  it("change de jour quand l'heure locale est encore la veille", () => {
    expect(formaterDateHeure("2026-10-06T02:15:00Z", "fr")).toBe("2026-10-05 22 h 15");
  });
});

describe("joursRestants et compteurs d'echeance", () => {
  it("une demande due aujourd'hui a 0 jour restant et n'est pas en retard", () => {
    fixerMaintenant("2026-10-06T09:00:00-04:00");
    expect(joursRestants("2026-10-06")).toBe(0);
    expect(estEnRetard("2026-10-06")).toBe(false);
  });

  it("une demande due hier est en retard", () => {
    fixerMaintenant("2026-10-06T09:00:00-04:00");
    expect(joursRestants("2026-10-05")).toBe(-1);
    expect(estEnRetard("2026-10-05")).toBe(true);
  });

  it("le seuil de 5 jours inclut le 5e jour et exclut le 6e", () => {
    fixerMaintenant("2026-10-06T09:00:00-04:00");
    expect(estBientotEcheance("2026-10-11")).toBe(true);
    expect(estBientotEcheance("2026-10-12")).toBe(false);
  });

  it("le resultat ne depend pas de l'heure de la journee", () => {
    fixerMaintenant("2026-10-06T23:30:00-04:00");
    expect(joursRestants("2026-10-07")).toBe(1);
  });

  it("compte juste a travers le passage a l'heure normale (journee de 25 h)", () => {
    fixerMaintenant("2026-10-31T09:00:00-04:00");
    expect(joursRestants("2026-11-02")).toBe(2);
  });
});

describe("date du jour", () => {
  it("reste sur la date locale apres 20 h a Ottawa (deja le lendemain en UTC)", () => {
    fixerMaintenant("2026-10-06T21:00:00-04:00");
    expect(aujourdhuiISO()).toBe("2026-10-06");
    expect(dansNJours(15)).toBe("2026-10-21");
  });
});

describe("ajouterJours (echeance legale de 30 jours)", () => {
  it("calcule reception + 30 jours", () => {
    expect(ajouterJours("2026-10-06", 30)).toBe("2026-11-05");
  });

  it("ne perd aucun jour au passage a l'heure avancee (mars)", () => {
    expect(ajouterJours("2026-03-01", 30)).toBe("2026-03-31");
  });

  it("gere le changement d'annee et les annees bissextiles", () => {
    expect(ajouterJours("2026-12-15", 30)).toBe("2027-01-14");
    expect(ajouterJours("2028-02-15", 30)).toBe("2028-03-16");
  });
});
