import { test, expect } from "@playwright/test";
import AxeBuilder from "@axe-core/playwright";

// Voir tests/README.md pour la portee (pas d'hote Power Apps, donc pas de
// donnees Dataverse reelles dans ces tests).

const ECRANS = [
  { route: "/", nom: "Tableau de bord" },
  { route: "/liste", nom: "Liste des demandes" },
  { route: "/nouvelle", nom: "Nouvelle demande" },
];

for (const ecran of ECRANS) {
  test(`aucune violation axe-core (WCAG 2.1 AA) sur ${ecran.nom}`, async ({ page }) => {
    await page.goto(ecran.route, { waitUntil: "domcontentloaded" });
    await page.waitForTimeout(500);

    const resultats = await new AxeBuilder({ page })
      .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa"])
      .analyze();

    expect(resultats.violations, JSON.stringify(resultats.violations, null, 2)).toEqual([]);
  });
}

test("le lien d'evitement est le premier element atteignable au clavier", async ({ page }) => {
  await page.goto("/");
  await page.keyboard.press("Tab");
  const lien = page.locator(".lien-evitement");
  await expect(lien).toBeFocused();
  await expect(lien).toBeVisible();
});

test("la bascule de langue traduit l'interface et met a jour lang du document", async ({ page }) => {
  // GcdsHeading (composant web) ne remplit pas textContent de facon lisible
  // par toHaveText ; le nom accessible, lui, est correct (verifie via
  // getByRole) - on s'appuie donc sur les locators par role, la pratique
  // recommandee par Playwright de toute facon.
  // Identifiant stable plutot que le nom accessible (qui change dynamiquement
  // avec la langue - voir Layout.tsx) : plus robuste pour cibler le bouton.
  const boutonLangue = page.locator("#bouton-langue");

  await page.goto("/");
  await expect(page.getByRole("heading", { level: 1, name: "Suivi AIPRP" })).toBeVisible();
  await expect(page.locator("html")).toHaveAttribute("lang", "fr");
  await expect(boutonLangue).toHaveAccessibleName("Passer en anglais");

  await boutonLangue.click();

  await expect(page.getByRole("heading", { level: 1, name: "ATIP Tracker" })).toBeVisible();
  await expect(page.locator("html")).toHaveAttribute("lang", "en");
  await expect(boutonLangue).toHaveAccessibleName("Switch to French");
});

test("la navigation principale est accessible au clavier", async ({ page }) => {
  await page.goto("/");
  const liste = page.getByRole("navigation", { name: "Navigation principale" });
  await expect(liste.getByRole("link", { name: "Tableau de bord" })).toBeVisible();
  await expect(liste.getByRole("link", { name: "Liste des demandes" })).toBeVisible();
  await expect(liste.getByRole("link", { name: "Nouvelle demande" })).toBeVisible();

  await liste.getByRole("link", { name: "Liste des demandes" }).focus();
  await page.keyboard.press("Enter");
  await expect(page).toHaveURL(/\/liste$/);
});
