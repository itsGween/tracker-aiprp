import { describe, expect, it } from "vitest";
import {
  STATUT_COMPLETEE,
  STATUT_EN_TRAITEMENT,
  STATUT_FERMEE,
  STATUT_PROROGATION_DEMANDEE,
  STATUT_PROROGEE,
  STATUT_RECUE,
  estStatutVerrouille,
  peutDemanderProrogation,
  statutsProposes,
} from "./statuts";

const STATUTS_ORDINAIRES = [STATUT_RECUE, STATUT_EN_TRAITEMENT, STATUT_COMPLETEE, STATUT_FERMEE];

describe("statutsProposes", () => {
  it.each(STATUTS_ORDINAIRES)("ne propose aucun statut de prorogation depuis %i", (statut) => {
    expect(statutsProposes(statut)).toEqual(STATUTS_ORDINAIRES);
  });

  it("garde le statut courant d'une demande prorogee, sans proposer Recue", () => {
    expect(statutsProposes(STATUT_PROROGEE)).toEqual([
      STATUT_PROROGEE,
      STATUT_EN_TRAITEMENT,
      STATUT_COMPLETEE,
      STATUT_FERMEE,
    ]);
  });

  it("ne propose rien pendant une prorogation en attente", () => {
    expect(statutsProposes(STATUT_PROROGATION_DEMANDEE)).toEqual([]);
  });

  it("ne permet jamais de choisir Prorogation demandee", () => {
    for (const statut of [...STATUTS_ORDINAIRES, STATUT_PROROGEE, undefined]) {
      expect(statutsProposes(statut)).not.toContain(STATUT_PROROGATION_DEMANDEE);
    }
  });
});

describe("estStatutVerrouille", () => {
  it("verrouille seulement une prorogation en attente", () => {
    expect(estStatutVerrouille(STATUT_PROROGATION_DEMANDEE)).toBe(true);
    expect(estStatutVerrouille(STATUT_PROROGEE)).toBe(false);
    expect(estStatutVerrouille(STATUT_EN_TRAITEMENT)).toBe(false);
  });
});

describe("peutDemanderProrogation", () => {
  it("n'est permis qu'au statut En traitement", () => {
    expect(peutDemanderProrogation(STATUT_EN_TRAITEMENT)).toBe(true);
    for (const statut of [
      STATUT_RECUE,
      STATUT_PROROGEE,
      STATUT_COMPLETEE,
      STATUT_FERMEE,
      STATUT_PROROGATION_DEMANDEE,
      undefined,
    ]) {
      expect(peutDemanderProrogation(statut)).toBe(false);
    }
  });
});
