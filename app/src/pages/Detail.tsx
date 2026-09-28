import { useCallback, useEffect, useState } from "react";
import { useNavigate, useParams } from "react-router-dom";
import { GcdsButton, GcdsHeading, GcdsNotice, GcdsText } from "@gcds-core/components-react";
import { Gk_demandesService } from "../generated/services/Gk_demandesService";
import { Gk_activitesService } from "../generated/services/Gk_activitesService";
import type { Gk_demandes } from "../generated/models/Gk_demandesModel";
import type { Gk_activites } from "../generated/models/Gk_activitesModel";
import { useLanguage } from "../context/LanguageContext";
import { formaterDate, aujourdhuiISO, dansNJours } from "../utils/dates";

const STATUT_RECUE = 100000010;
const STATUT_EN_TRAITEMENT = 100000011;
const STATUT_PROROGEE = 100000012;
const STATUT_COMPLETEE = 100000013;
const STATUT_FERMEE = 100000014;
const STATUTS = [STATUT_RECUE, STATUT_EN_TRAITEMENT, STATUT_PROROGEE, STATUT_COMPLETEE, STATUT_FERMEE] as const;

const ACTION_CHANGEMENT_STATUT = 100000031;
const ACTION_COMMENTAIRE = 100000032;
const ACTION_PROROGATION_DEMANDEE = 100000033;
const ACTION_FERMETURE = 100000035;

export function Detail() {
  const { id } = useParams<{ id: string }>();
  const { t, langue } = useLanguage();
  const navigate = useNavigate();

  const [demande, setDemande] = useState<Gk_demandes | null>(null);
  const [activites, setActivites] = useState<Gk_activites[]>([]);
  const [chargement, setChargement] = useState(true);
  const [erreur, setErreur] = useState<string | null>(null);
  const [enregistrement, setEnregistrement] = useState(false);

  const [nouveauStatut, setNouveauStatut] = useState<number>(STATUT_RECUE);
  const [commentaire, setCommentaire] = useState("");
  const [motifProrogation, setMotifProrogation] = useState("");
  const [nouvelleEcheance, setNouvelleEcheance] = useState(dansNJours(15));

  const charger = useCallback(async () => {
    if (!id) return;
    setChargement(true);
    const [resultatDemande, resultatActivites] = await Promise.all([
      Gk_demandesService.get(id),
      Gk_activitesService.getAll({
        filter: `_gk_demandeid_value eq ${id}`,
        orderBy: ["gk_date desc"],
      }),
    ]);
    if (resultatDemande.success) {
      setDemande(resultatDemande.data);
      setNouveauStatut(resultatDemande.data.gk_statut ?? STATUT_RECUE);
    } else {
      setErreur(resultatDemande.error?.message ?? "Erreur de chargement de la demande.");
    }
    if (resultatActivites.success) {
      setActivites(resultatActivites.data);
    }
    setChargement(false);
  }, [id]);

  useEffect(() => {
    // eslint-disable-next-line react-hooks/set-state-in-effect -- chargement des donnees au montage, motif standard
    void charger();
  }, [charger]);

  if (chargement) {
    return <GcdsText>{langue === "fr" ? "Chargement..." : "Loading..."}</GcdsText>;
  }
  if (erreur || !demande || !id) {
    return (
      <GcdsNotice noticeRole="danger" noticeTitle={erreur ?? "Demande introuvable"} noticeTitleTag="h2">
        {erreur ?? "Demande introuvable"}
      </GcdsNotice>
    );
  }

  async function ajouterActivite(action: number, texteCommentaire: string) {
    await Gk_activitesService.create({
      gk_action: action as never,
      gk_commentaire: texteCommentaire,
      gk_date: new Date().toISOString(),
      "gk_DemandeId@odata.bind": `/gk_demandes(${id})`,
      statecode: 0 as never,
    });
  }

  async function enregistrerCommentaire() {
    if (!commentaire.trim()) return;
    setEnregistrement(true);
    await ajouterActivite(ACTION_COMMENTAIRE, commentaire.trim());
    setCommentaire("");
    await charger();
    setEnregistrement(false);
  }

  async function enregistrerStatut() {
    if (!id || !demande || nouveauStatut === demande.gk_statut) return;
    setEnregistrement(true);
    await Gk_demandesService.update(id, { gk_statut: nouveauStatut as never });
    await ajouterActivite(
      nouveauStatut === STATUT_FERMEE ? ACTION_FERMETURE : ACTION_CHANGEMENT_STATUT,
      `${t("detail_statut")}: ${t(`choix_${nouveauStatut}` as const)}`
    );
    await charger();
    setEnregistrement(false);
  }

  async function demanderProrogation() {
    if (!id || !motifProrogation.trim()) return;
    setEnregistrement(true);
    await Gk_demandesService.update(id, {
      gk_statut: STATUT_PROROGEE as never,
      gk_motifprorogation: motifProrogation.trim(),
      gk_nouvelleecheanceprorogation: nouvelleEcheance,
    });
    await ajouterActivite(ACTION_PROROGATION_DEMANDEE, motifProrogation.trim());
    setMotifProrogation("");
    await charger();
    setEnregistrement(false);
  }

  // L'approbation de la prorogation n'est plus faite par l'app (separation des
  // taches : l'agent·e demande, la gestionnaire approuve). C'est le flux
  // Power Automate "Approbation de prorogation" qui met a jour gk_statut,
  // gk_dateecheance et le journal une fois la demande approuvee ou rejetee -
  // voir docs/adr/0003-approbation-prorogation-par-flux.md et docs/flux.md.

  return (
    <>
      <GcdsButton type="button" buttonRole="secondary" size="small" onGcdsClick={() => navigate("/liste")}>
        {t("detail_retour")}
      </GcdsButton>

      <GcdsHeading tag="h2">
        {t("detail_titre")} — {demande.gk_name}
      </GcdsHeading>

      <dl className="fiche">
        <div>
          <dt>{t("detail_type")}</dt>
          <dd>{demande.gk_type !== undefined ? t(`choix_${demande.gk_type}` as const) : ""}</dd>
        </div>
        <div>
          <dt>{t("detail_demandeur")}</dt>
          <dd>{demande.gk_nomdemandeur}</dd>
        </div>
        <div>
          <dt>{t("detail_courriel")}</dt>
          <dd>{demande.gk_courrieldemandeur}</dd>
        </div>
        <div>
          <dt>{t("detail_objet")}</dt>
          <dd>{demande.gk_objet}</dd>
        </div>
        <div>
          <dt>{t("detail_reception")}</dt>
          <dd>{formaterDate(demande.gk_datereception, langue)}</dd>
        </div>
        <div>
          <dt>{t("detail_echeance")}</dt>
          <dd>{formaterDate(demande.gk_dateecheance, langue)}</dd>
        </div>
        <div>
          <dt>{t("detail_classification")}</dt>
          <dd>{demande.gk_classification !== undefined ? t(`choix_${demande.gk_classification}` as const) : ""}</dd>
        </div>
      </dl>

      <section aria-labelledby="statut-titre">
        <GcdsHeading tag="h3" id="statut-titre">
          {t("detail_statut")}
        </GcdsHeading>
        <div className="champ champ--inline">
          <label htmlFor="statut-select" className="sr-only">
            {t("detail_statut")}
          </label>
          <select
            id="statut-select"
            value={nouveauStatut}
            onChange={(e) => setNouveauStatut(Number(e.target.value))}
          >
            {STATUTS.map((s) => (
              <option key={s} value={s}>
                {t(`choix_${s}` as const)}
              </option>
            ))}
          </select>
          <GcdsButton
            type="button"
            buttonRole="primary"
            size="small"
            disabled={enregistrement || nouveauStatut === demande.gk_statut}
            onGcdsClick={enregistrerStatut}
          >
            {t("detail_enregistrer")}
          </GcdsButton>
        </div>
      </section>

      {demande.gk_statut === STATUT_PROROGEE && demande.gk_nouvelleecheanceprorogation && (
        <GcdsNotice noticeRole="warning" noticeTitle={t("detail_prorogation_en_attente")} noticeTitleTag="h3">
          <GcdsText>
            {t("detail_motif_prorogation")}: {demande.gk_motifprorogation}
            <br />
            {t("detail_echeance")}: {formaterDate(demande.gk_nouvelleecheanceprorogation, langue)}
          </GcdsText>
        </GcdsNotice>
      )}

      {demande.gk_statut !== STATUT_PROROGEE &&
        demande.gk_statut !== STATUT_COMPLETEE &&
        demande.gk_statut !== STATUT_FERMEE && (
          <section aria-labelledby="prorogation-titre">
            <GcdsHeading tag="h3" id="prorogation-titre">
              {t("detail_demander_prorogation")}
            </GcdsHeading>
            <div className="champ">
              <label htmlFor="motif-prorogation">{t("detail_motif_prorogation")}</label>
              <textarea
                id="motif-prorogation"
                value={motifProrogation}
                onChange={(e) => setMotifProrogation(e.target.value)}
                rows={3}
              />
            </div>
            <div className="champ">
              <label htmlFor="nouvelle-echeance">{t("detail_echeance")}</label>
              <input
                id="nouvelle-echeance"
                type="date"
                value={nouvelleEcheance}
                min={aujourdhuiISO()}
                onChange={(e) => setNouvelleEcheance(e.target.value)}
              />
            </div>
            <GcdsButton
              type="button"
              buttonRole="secondary"
              disabled={enregistrement || !motifProrogation.trim()}
              onGcdsClick={demanderProrogation}
            >
              {t("detail_demander_prorogation")}
            </GcdsButton>
          </section>
        )}

      <section aria-labelledby="activites-titre">
        <GcdsHeading tag="h3" id="activites-titre">
          {t("detail_activites")}
        </GcdsHeading>
        <ul className="journal-activite">
          {activites.map((a) => (
            <li key={a.gk_activiteid}>
              <span className="journal-activite__date">{formaterDate(a.gk_date, langue)}</span>
              <span className="journal-activite__action">
                {a.gk_action !== undefined ? t(`choix_${a.gk_action}` as const) : ""}
              </span>
              {a.gk_commentaire && <p>{a.gk_commentaire}</p>}
            </li>
          ))}
        </ul>

        <div className="champ">
          <label htmlFor="nouveau-commentaire">{t("detail_ajouter_commentaire")}</label>
          <textarea
            id="nouveau-commentaire"
            value={commentaire}
            onChange={(e) => setCommentaire(e.target.value)}
            rows={3}
          />
        </div>
        <GcdsButton
          type="button"
          buttonRole="secondary"
          disabled={enregistrement || !commentaire.trim()}
          onGcdsClick={enregistrerCommentaire}
        >
          {t("detail_ajouter_commentaire")}
        </GcdsButton>
      </section>
    </>
  );
}
