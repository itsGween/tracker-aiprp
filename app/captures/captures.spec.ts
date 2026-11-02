import { test, expect } from "@playwright/test";

// Captures d'ecran pour la documentation (npm run captures), pas des tests.
// Seuls les ecrans sans donnees Dataverse sont captures ici : l'application
// tourne sans hote Power Apps (voir tests/README.md). Les ecrans remplis sont
// captures dans l'application publiee (voir docs/captures.md).

const DOSSIER = "../docs/images";

test("formulaire Nouvelle demande rempli", async ({ page }) => {
  await page.goto("/nouvelle");
  await page.getByLabel("Nom du demandeur *").fill("Camille Lefebvre");
  await page.getByLabel("Courriel du demandeur").fill("camille.lefebvre@example.com");
  await page.getByLabel("Objet de la demande").fill("Copie des rapports d'entretien de la flotte de véhicules pour 2025");
  await page.getByLabel("Classification").selectOption({ index: 1 });
  await page.screenshot({ path: `${DOSSIER}/04-app-nouvelle-demande.png`, fullPage: true });
});

test("resume d'erreurs accessible", async ({ page }) => {
  await page.goto("/nouvelle");
  await page.getByRole("button", { name: "Soumettre" }).click();
  await expect(page.getByRole("heading", { name: "Veuillez remplir tous les champs obligatoires." })).toBeVisible();
  await page.screenshot({ path: `${DOSSIER}/05-app-resume-erreurs.png`, fullPage: true });
});

test("lien d'evitement au clavier", async ({ page }) => {
  await page.goto("/nouvelle");
  await page.keyboard.press("Tab");
  await expect(page.locator(".lien-evitement")).toBeFocused();
  await page.screenshot({ path: `${DOSSIER}/07-app-lien-evitement.png` });
});
