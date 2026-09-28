import { useState, type FormEvent } from "react";
import { useNavigate } from "react-router-dom";
import { GcdsButton, GcdsHeading, GcdsNotice } from "@gcds-core/components-react";
import { Gk_demandesService } from "../generated/services/Gk_demandesService";
import { Gk_activitesService } from "../generated/services/Gk_activitesService";
import { useLanguage } from "../context/LanguageContext";
import { aujourdhuiISO } from "../utils/dates";

const TYPE_ACCES = 100000000;
const TYPE_RENSEIGNEMENTS = 100000001;
const STATUT_RECUE = 100000010;
const CLASSE_NON_CLASSIFIE = 100000020;
const CLASSE_PROTEGE_A = 100000021;
const CLASSE_PROTEGE_B = 100000022;
const ACTION_DEMANDE_RECUE = 100000030;

interface FormState {
  type: number;
  nomDemandeur: string;
  courrielDemandeur: string;
  objet: string;
  dateReception: string;
  classification: number;
}

const ETAT_INITIAL: FormState = {
  type: TYPE_ACCES,
  nomDemandeur: "",
  courrielDemandeur: "",
  objet: "",
  dateReception: aujourdhuiISO(),
  classification: CLASSE_NON_CLASSIFIE,
};

export function NouvelleDemande() {
  const { t } = useLanguage();
  const navigate = useNavigate();
  const [form, setForm] = useState<FormState>(ETAT_INITIAL);
  const [erreurs, setErreurs] = useState<string[]>([]);
  const [enregistrement, setEnregistrement] = useState(false);
  const [succes, setSucces] = useState(false);

  function validation(): string[] {
    const problemes: string[] = [];
    if (!form.nomDemandeur.trim()) problemes.push(t("nouvelle_nomdemandeur"));
    if (!form.dateReception) problemes.push(t("nouvelle_reception"));
    return problemes;
  }

  async function soumettre(e: FormEvent) {
    e.preventDefault();
    const problemes = validation();
    setErreurs(problemes);
    if (problemes.length > 0) return;

    setEnregistrement(true);

    // La date d'echeance (reception + 30 jours) est normalement calculee par le
    // flux "Demande recue" (Phase 3, pas encore construit). En attendant, la
    // code app assume ce calcul directement - voir docs/modele-donnees.md.
    const dateEcheance = new Date(form.dateReception);
    dateEcheance.setDate(dateEcheance.getDate() + 30);

    const resultat = await Gk_demandesService.create({
      gk_type: form.type as never,
      gk_nomdemandeur: form.nomDemandeur.trim(),
      gk_courrieldemandeur: form.courrielDemandeur.trim() || undefined,
      gk_objet: form.objet.trim() || undefined,
      gk_datereception: form.dateReception,
      gk_dateecheance: dateEcheance.toISOString().split("T")[0],
      gk_statut: STATUT_RECUE as never,
      gk_classification: form.classification as never,
      statecode: 0 as never,
    });

    if (!resultat.success) {
      setErreurs([resultat.error?.message ?? "Erreur lors de la creation de la demande."]);
      setEnregistrement(false);
      return;
    }

    await Gk_activitesService.create({
      gk_action: ACTION_DEMANDE_RECUE as never,
      gk_commentaire: "",
      gk_date: new Date().toISOString(),
      "gk_DemandeId@odata.bind": `/gk_demandes(${resultat.data.gk_demandeid})`,
      statecode: 0 as never,
    });

    setSucces(true);
    setEnregistrement(false);
    setTimeout(() => navigate(`/detail/${resultat.data.gk_demandeid}`), 1200);
  }

  return (
    <>
      <GcdsHeading tag="h2">{t("nouvelle_titre")}</GcdsHeading>

      {succes && (
        <GcdsNotice noticeRole="success" noticeTitle={t("nouvelle_succes")} noticeTitleTag="h3">
          {t("nouvelle_succes")}
        </GcdsNotice>
      )}

      {erreurs.length > 0 && (
        <GcdsNotice noticeRole="danger" noticeTitle={t("nouvelle_erreur_champs")} noticeTitleTag="h3">
          <ul>
            {erreurs.map((err) => (
              <li key={err}>{err}</li>
            ))}
          </ul>
        </GcdsNotice>
      )}

      <form onSubmit={soumettre} noValidate>
        <div className="champ">
          <label htmlFor="type">{t("nouvelle_type")}</label>
          <select
            id="type"
            value={form.type}
            onChange={(e) => setForm({ ...form, type: Number(e.target.value) })}
          >
            <option value={TYPE_ACCES}>{t("choix_100000000")}</option>
            <option value={TYPE_RENSEIGNEMENTS}>{t("choix_100000001")}</option>
          </select>
        </div>

        <div className="champ">
          <label htmlFor="nom-demandeur">
            {t("nouvelle_nomdemandeur")} <span aria-hidden="true">*</span>
          </label>
          <input
            id="nom-demandeur"
            type="text"
            required
            value={form.nomDemandeur}
            onChange={(e) => setForm({ ...form, nomDemandeur: e.target.value })}
          />
        </div>

        <div className="champ">
          <label htmlFor="courriel-demandeur">{t("nouvelle_courriel")}</label>
          <input
            id="courriel-demandeur"
            type="email"
            value={form.courrielDemandeur}
            onChange={(e) => setForm({ ...form, courrielDemandeur: e.target.value })}
          />
        </div>

        <div className="champ">
          <label htmlFor="objet">{t("nouvelle_objet")}</label>
          <textarea
            id="objet"
            rows={4}
            value={form.objet}
            onChange={(e) => setForm({ ...form, objet: e.target.value })}
          />
        </div>

        <div className="champ">
          <label htmlFor="date-reception">
            {t("nouvelle_reception")} <span aria-hidden="true">*</span>
          </label>
          <input
            id="date-reception"
            type="date"
            required
            value={form.dateReception}
            onChange={(e) => setForm({ ...form, dateReception: e.target.value })}
          />
        </div>

        <div className="champ">
          <label htmlFor="classification">{t("nouvelle_classification")}</label>
          <select
            id="classification"
            value={form.classification}
            onChange={(e) => setForm({ ...form, classification: Number(e.target.value) })}
          >
            <option value={CLASSE_NON_CLASSIFIE}>{t("choix_100000020")}</option>
            <option value={CLASSE_PROTEGE_A}>{t("choix_100000021")}</option>
            <option value={CLASSE_PROTEGE_B}>{t("choix_100000022")}</option>
          </select>
        </div>

        <div className="champ champ--inline">
          <GcdsButton type="submit" buttonRole="primary" disabled={enregistrement}>
            {t("nouvelle_soumettre")}
          </GcdsButton>
          <GcdsButton
            type="button"
            buttonRole="secondary"
            onGcdsClick={() => navigate("/liste")}
          >
            {t("nouvelle_annuler")}
          </GcdsButton>
        </div>
      </form>
    </>
  );
}
