import { WhoAmIService } from "../generated/services/WhoAmIService";

// La colonne gk_auteurid attend un systemuserid. getContext() du SDK ne donne
// que l'ID Entra : c'est WhoAmI qui renvoie l'identifiant Dataverse.
let idUtilisateur: string | undefined;

async function obtenirIdUtilisateur(): Promise<string | undefined> {
  if (idUtilisateur) return idUtilisateur;
  try {
    const resultat = await WhoAmIService.WhoAmI();
    const id = resultat.success ? resultat.data.UserId : undefined;
    if (typeof id === "string") idUtilisateur = id;
  } catch (e) {
    console.warn("WhoAmI a echoue", e);
  }
  return idUtilisateur;
}

// Champ a ajouter a une nouvelle activite. Sans auteur connu, on ecrit quand
// meme l'activite : une entree de journal sans auteur vaut mieux qu'aucune.
export async function champAuteur(): Promise<{ "gk_AuteurId@odata.bind"?: string }> {
  const id = await obtenirIdUtilisateur();
  return id ? { "gk_AuteurId@odata.bind": `/systemusers(${id})` } : {};
}
