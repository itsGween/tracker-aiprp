import { defineConfig, devices } from "@playwright/test";

// Voir tests/README.md pour la portee et les limites de ces tests
// (l'app tourne sans l'hote Power Apps, donc sans connexion Dataverse reelle).
export default defineConfig({
  testDir: "./tests",
  // Un seul serveur Vite de dev partage par tous les tests : on serialise
  // pour eviter la contention (compilation a la demande d'un seul processus).
  fullyParallel: false,
  workers: 1,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  reporter: "html",
  use: {
    baseURL: "http://localhost:5173",
    trace: "on-first-retry",
  },
  projects: [{ name: "chromium", use: { ...devices["Desktop Chrome"] } }],
  webServer: {
    command: "npm run dev",
    url: "http://localhost:5173",
    reuseExistingServer: !process.env.CI,
    timeout: 30000,
  },
});
