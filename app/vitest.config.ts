import { defineConfig } from "vitest/config";

// Fixe avant le demarrage des processus de test : le fuseau d'Ottawa est
// celui ou le decalage des dates "date seule" se produit (UTC-4 ou UTC-5).
process.env.TZ = "America/Toronto";

export default defineConfig({
  test: {
    include: ["src/**/*.test.ts"],
  },
});
