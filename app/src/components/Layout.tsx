import type { ReactNode } from "react";
import { NavLink } from "react-router-dom";
import { GcdsButton, GcdsContainer, GcdsHeading } from "@gcds-core/components-react";
import { useLanguage } from "../context/LanguageContext";

interface LayoutProps {
  children: ReactNode;
}

export function Layout({ children }: LayoutProps) {
  const { t, basculerLangue, langue } = useLanguage();

  const classeNavLink = ({ isActive }: { isActive: boolean }) =>
    isActive ? "nav-lien nav-lien--actif" : "nav-lien";

  return (
    <div lang={langue}>
      <a href="#contenu-principal" className="lien-evitement">
        {langue === "fr" ? "Aller au contenu principal" : "Skip to main content"}
      </a>
      <header className="entete">
        <GcdsContainer size="xl" layout="page">
          <div className="entete__barre">
            <GcdsHeading tag="h1" marginBottom="0">
              {t("app_titre")}
            </GcdsHeading>
            <GcdsButton
              type="button"
              buttonRole="secondary"
              size="small"
              onGcdsClick={basculerLangue}
              aria-label={langue === "fr" ? "Passer en anglais" : "Switch to French"}
            >
              {t("bouton_langue")}
            </GcdsButton>
          </div>
          <nav aria-label={langue === "fr" ? "Navigation principale" : "Main navigation"}>
            <ul className="nav-liste">
              <li>
                <NavLink to="/" end className={classeNavLink}>
                  {t("nav_tableau_bord")}
                </NavLink>
              </li>
              <li>
                <NavLink to="/liste" className={classeNavLink}>
                  {t("nav_liste")}
                </NavLink>
              </li>
              <li>
                <NavLink to="/nouvelle" className={classeNavLink}>
                  {t("nav_nouvelle")}
                </NavLink>
              </li>
            </ul>
          </nav>
        </GcdsContainer>
      </header>
      <main id="contenu-principal">
        <GcdsContainer size="xl" layout="page">
          {children}
        </GcdsContainer>
      </main>
    </div>
  );
}
