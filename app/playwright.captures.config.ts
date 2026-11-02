import { defineConfig, devices } from "@playwright/test";

// Captures d'ecran de la documentation (npm run captures). Separe des tests
// pour ne pas ecrire d'images a chaque execution de la suite.
export default defineConfig({
  testDir: "./captures",
  workers: 1,
  reporter: "line",
  use: {
    ...devices["Desktop Chrome"],
    baseURL: "http://localhost:5173",
    viewport: { width: 1280, height: 800 },
    locale: "fr-CA",
    // Le format des champs date suit la langue du navigateur, pas la locale.
    launchOptions: { args: ["--lang=fr-CA"] },
  },
  webServer: {
    command: "npm run dev",
    url: "http://localhost:5173",
    reuseExistingServer: true,
    timeout: 30000,
  },
});
