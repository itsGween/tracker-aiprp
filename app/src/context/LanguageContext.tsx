import { createContext, useContext, useEffect, useState, type ReactNode } from "react";
import { traductions } from "../i18n/traductions";

export type LangueCode = "fr" | "en";

interface LanguageContextValue {
  langue: LangueCode;
  basculerLangue: () => void;
  t: (cle: keyof typeof traductions) => string;
}

const LanguageContext = createContext<LanguageContextValue | undefined>(undefined);

export function LanguageProvider({ children }: { children: ReactNode }) {
  const [langue, setLangue] = useState<LangueCode>("fr");

  const basculerLangue = () => setLangue((l) => (l === "fr" ? "en" : "fr"));

  useEffect(() => {
    document.documentElement.lang = langue;
  }, [langue]);

  const t = (cle: keyof typeof traductions): string => {
    const entree = traductions[cle];
    if (!entree) {
      console.warn(`Traduction manquante pour la cle: ${String(cle)}`);
      return String(cle);
    }
    return entree[langue];
  };

  return (
    <LanguageContext.Provider value={{ langue, basculerLangue, t }}>
      {children}
    </LanguageContext.Provider>
  );
}

// eslint-disable-next-line react-refresh/only-export-components -- hook regroupe volontairement avec son contexte
export function useLanguage(): LanguageContextValue {
  const context = useContext(LanguageContext);
  if (!context) {
    throw new Error("useLanguage doit etre utilise a l'interieur d'un LanguageProvider");
  }
  return context;
}
