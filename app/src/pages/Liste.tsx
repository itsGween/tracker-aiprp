import { useEffect, useMemo, useState } from "react";
import { useNavigate } from "react-router-dom";
import { GcdsHeading, GcdsNotice, GcdsText } from "@gcds-core/components-react";
import { Gk_demandesService } from "../generated/services/Gk_demandesService";
import type { Gk_demandes } from "../generated/models/Gk_demandesModel";
import { useLanguage } from "../context/LanguageContext";
import { formaterDate } from "../utils/dates";

const STATUTS = [100000010, 100000011, 100000015, 100000012, 100000013, 100000014] as const;

export function Liste() {
  const { t, langue } = useLanguage();
  const navigate = useNavigate();
  const [demandes, setDemandes] = useState<Gk_demandes[]>([]);
  const [chargement, setChargement] = useState(true);
  const [erreur, setErreur] = useState<string | null>(null);
  const [recherche, setRecherche] = useState("");
  const [filtreStatut, setFiltreStatut] = useState<string>("tous");

  useEffect(() => {
    let annule = false;
    async function charger() {
      const resultat = await Gk_demandesService.getAll({ top: 500, orderBy: ["gk_dateecheance asc"] });
      if (annule) return;
      if (resultat.success) {
        setDemandes(resultat.data);
      } else {
        setErreur(resultat.error?.message ?? "Erreur de chargement des demandes.");
      }
      setChargement(false);
    }
    void charger();
    return () => {
      annule = true;
    };
  }, []);

  const demandesFiltrees = useMemo(() => {
    const rechercheLower = recherche.trim().toLowerCase();
    return demandes.filter((d) => {
      const correspondRecherche =
        rechercheLower === "" ||
        d.gk_nomdemandeur?.toLowerCase().includes(rechercheLower) ||
        d.gk_objet?.toLowerCase().includes(rechercheLower) ||
        d.gk_name?.toLowerCase().includes(rechercheLower);
      const correspondStatut = filtreStatut === "tous" || String(d.gk_statut) === filtreStatut;
      return correspondRecherche && correspondStatut;
    });
  }, [demandes, recherche, filtreStatut]);

  if (chargement) {
    return <GcdsText>{langue === "fr" ? "Chargement..." : "Loading..."}</GcdsText>;
  }
  if (erreur) {
    return (
      <GcdsNotice noticeRole="danger" noticeTitle={erreur} noticeTitleTag="h2">
        {erreur}
      </GcdsNotice>
    );
  }

  return (
    <>
      <GcdsHeading tag="h2">{t("liste_titre")}</GcdsHeading>

      <div className="filtres">
        <div className="champ">
          <label htmlFor="recherche">{t("liste_recherche_placeholder")}</label>
          <input
            id="recherche"
            type="search"
            value={recherche}
            onChange={(e) => setRecherche(e.target.value)}
          />
        </div>
        <div className="champ">
          <label htmlFor="filtre-statut">{t("liste_filtre_statut")}</label>
          <select id="filtre-statut" value={filtreStatut} onChange={(e) => setFiltreStatut(e.target.value)}>
            <option value="tous">{t("liste_tous")}</option>
            {STATUTS.map((s) => (
              <option key={s} value={s}>
                {t(`choix_${s}` as const)}
              </option>
            ))}
          </select>
        </div>
      </div>

      <table className="tableau-demandes">
        <caption className="sr-only">{t("liste_titre")}</caption>
        <thead>
          <tr>
            <th scope="col">{t("liste_col_numero")}</th>
            <th scope="col">{t("liste_col_demandeur")}</th>
            <th scope="col">{t("liste_col_statut")}</th>
            <th scope="col">{t("liste_col_echeance")}</th>
          </tr>
        </thead>
        <tbody>
          {demandesFiltrees.map((d) => (
            <tr key={d.gk_demandeid}>
              <th scope="row">
                <button type="button" className="lien-bouton" onClick={() => navigate(`/detail/${d.gk_demandeid}`)}>
                  {d.gk_name}
                </button>
              </th>
              <td>{d.gk_nomdemandeur}</td>
              <td>{d.gk_statut ? t(`choix_${d.gk_statut}` as const) : ""}</td>
              <td>{formaterDate(d.gk_dateecheance, langue)}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </>
  );
}
