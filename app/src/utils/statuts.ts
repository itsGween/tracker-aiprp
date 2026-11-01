// Regles de statut de l'ecran Detail. "Prorogation demandee" n'est pose que par
// le bouton de prorogation, "Prorogee" que par le flux d'approbation (ADR 0003).
// Ce blocage est cote interface : les roles de securite le renforcent cote Dataverse.

export const STATUT_RECUE = 100000010;
export const STATUT_EN_TRAITEMENT = 100000011;
export const STATUT_PROROGEE = 100000012;
export const STATUT_COMPLETEE = 100000013;
export const STATUT_FERMEE = 100000014;
export const STATUT_PROROGATION_DEMANDEE = 100000015;

const STATUTS_MANUELS = [STATUT_RECUE, STATUT_EN_TRAITEMENT, STATUT_COMPLETEE, STATUT_FERMEE];

export function estStatutVerrouille(statut: number | undefined): boolean {
  return statut === STATUT_PROROGATION_DEMANDEE;
}

export function statutsProposes(statut: number | undefined): number[] {
  if (estStatutVerrouille(statut)) return [];
  if (statut === STATUT_PROROGEE) {
    return [STATUT_PROROGEE, STATUT_EN_TRAITEMENT, STATUT_COMPLETEE, STATUT_FERMEE];
  }
  return STATUTS_MANUELS;
}

export function peutDemanderProrogation(statut: number | undefined): boolean {
  return statut === STATUT_EN_TRAITEMENT;
}
