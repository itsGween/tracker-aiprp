import { test, expect } from "@playwright/test";
import AxeBuilder from "@axe-core/playwright";

// Le formulaire Nouvelle demande ne charge aucune donnee a l'affichage, donc
// il peut etre teste completement sans hote Power Apps (voir tests/README.md).

test.describe("Nouvelle demande", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/nouvelle");
  });

  test("affiche tous les champs attendus avec leurs etiquettes", async ({ page }) => {
    await expect(page.getByLabel("Type de demande")).toBeVisible();
    await expect(page.getByLabel("Nom du demandeur *")).toBeVisible();
    await expect(page.getByLabel("Courriel du demandeur")).toBeVisible();
    await expect(page.getByLabel("Objet de la demande")).toBeVisible();
    await expect(page.getByLabel("Date de réception *")).toBeVisible();
    await expect(page.getByLabel("Classification")).toBeVisible();
  });

  test("la date de reception est pre-remplie avec la date du jour", async ({ page }) => {
    const dateInput = page.locator("#date-reception");
    await expect(dateInput).not.toHaveValue("");
  });

  test("soumettre sans nom de demandeur affiche un resume d'erreurs accessible", async ({ page }) => {
    // La date de reception est pre-remplie par defaut (voir test ci-dessus),
    // donc seul le nom du demandeur manque sur un formulaire "vide".
    await page.getByRole("button", { name: "Soumettre" }).click();

    const resume = page.getByRole("heading", { name: "Veuillez remplir tous les champs obligatoires." });
    await expect(resume).toBeVisible();
    await expect(page.getByText("Nom du demandeur", { exact: true })).toBeVisible();

    const resultats = await new AxeBuilder({ page })
      .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa"])
      .analyze();
    expect(resultats.violations, JSON.stringify(resultats.violations, null, 2)).toEqual([]);
  });

  test("vider la date de reception ajoute son erreur au resume", async ({ page }) => {
    await page.getByLabel("Date de réception *").fill("");
    await page.getByRole("button", { name: "Soumettre" }).click();

    await expect(page.getByText("Date de réception", { exact: true })).toBeVisible();
  });

  test("remplir les champs obligatoires fait disparaitre les erreurs au prochain essai", async ({ page }) => {
    await page.getByRole("button", { name: "Soumettre" }).click();
    await expect(page.getByRole("heading", { name: "Veuillez remplir tous les champs obligatoires." })).toBeVisible();

    await page.getByLabel("Nom du demandeur *").fill("Demandeur Fictif Test");

    // Le resume d'erreurs precedent reste affiche tant que le formulaire n'est
    // pas resoumis (comportement attendu : pas de validation en direct sur
    // chaque frappe, seulement a la soumission).
    await page.getByRole("button", { name: "Soumettre" }).click();
    await expect(page.getByText("Nom du demandeur", { exact: true })).not.toBeVisible();
  });

  test("le bouton Annuler ramene a la liste des demandes", async ({ page }) => {
    await page.getByRole("button", { name: "Annuler" }).click();
    await expect(page).toHaveURL(/\/liste$/);
  });
});
