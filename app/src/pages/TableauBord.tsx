import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { GcdsHeading, GcdsNotice, GcdsText } from "@gcds-core/components-react";
import { Gk_demandesService } from "../generated/services/Gk_demandesService";
import type { Gk_demandes } from "../generated/models/Gk_demandesModel";
import { useLanguage } from "../context/LanguageContext";
import { estEnRetard, estBientotEcheance, formaterDate } from "../utils/dates";

const STATUTS = [
  { valeur: 100000010, cle: "dashboard_recues" },
  { valeur: 100000011, cle: "dashboard_entraitement" },
  { valeur: 100000012, cle: "dashboard_prorogees" },
  { valeur: 100000013, cle: "dashboard_completees" },
  { valeur: 100000014, cle: "dashboard_fermees" },
] as const;

const STATUT_COMPLETEE = 100000013;
const STATUT_FERMEE = 100000014;

export function TableauBord() {
  const { t, langue } = useLanguage();
  const navigate = useNavigate();
  const [demandes, setDemandes] = useState<Gk_demandes[]>([]);
  const [chargement, setChargement] = useState(true);
  const [erreur, setErreur] = useState<string | null>(null);

  useEffect(() => {
    let annule = false;
    async function charger() {
      const resultat = await Gk_demandesService.getAll({ top: 500 });
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

  const comptes = STATUTS.map((s) => ({
    ...s,
    total: demandes.filter((d) => d.gk_statut === s.valeur).length,
  }));

  const nonFermees = demandes.filter(
    (d) => d.gk_statut !== STATUT_COMPLETEE && d.gk_statut !== STATUT_FERMEE && d.gk_dateecheance
  );
  const enRetard = nonFermees.filter((d) => estEnRetard(d.gk_dateecheance!));
  const bientotEcheance = nonFermees.filter((d) => estBientotEcheance(d.gk_dateecheance!));

  return (
    <>
      <GcdsHeading tag="h2">{t("dashboard_titre")}</GcdsHeading>

      <ul className="tuiles" aria-label={t("dashboard_titre")}>
        {comptes.map((c) => (
          <li className="tuile" key={c.cle} aria-label={`${c.total} ${t(c.cle)}`}>
            <p className="tuile__nombre" aria-hidden="true">
              {c.total}
            </p>
            <p className="tuile__libelle" aria-hidden="true">
              {t(c.cle)}
            </p>
          </li>
        ))}
      </ul>

      {enRetard.length > 0 && (
        <GcdsNotice
          noticeRole="danger"
          noticeTitle={`${t("dashboard_enretard")} (${enRetard.length})`}
          noticeTitleTag="h3"
        >
          <ApercuDemandes demandes={enRetard} langue={langue} onSelection={(id) => navigate(`/detail/${id}`)} />
        </GcdsNotice>
      )}

      {bientotEcheance.length > 0 && (
        <GcdsNotice
          noticeRole="warning"
          noticeTitle={`${t("dashboard_bientotecheance")} (${bientotEcheance.length})`}
          noticeTitleTag="h3"
        >
          <ApercuDemandes demandes={bientotEcheance} langue={langue} onSelection={(id) => navigate(`/detail/${id}`)} />
        </GcdsNotice>
      )}
    </>
  );
}

interface ApercuDemandesProps {
  demandes: Gk_demandes[];
  langue: "fr" | "en";
  onSelection: (id: string) => void;
}

function ApercuDemandes({ demandes, langue, onSelection }: ApercuDemandesProps) {
  return (
    <ul className="apercu-liste">
      {demandes.map((d) => (
        <li key={d.gk_demandeid}>
          <button type="button" className="lien-bouton" onClick={() => onSelection(d.gk_demandeid)}>
            {d.gk_name} — {d.gk_nomdemandeur} ({formaterDate(d.gk_dateecheance, langue)})
          </button>
        </li>
      ))}
    </ul>
  );
}
