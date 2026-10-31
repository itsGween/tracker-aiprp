import { beforeEach, describe, expect, it, vi } from "vitest";

const whoAmI = vi.hoisted(() => vi.fn());
vi.mock("../generated/services/WhoAmIService", () => ({ WhoAmIService: { WhoAmI: whoAmI } }));

async function chargerModule() {
  vi.resetModules();
  return import("./auteur");
}

beforeEach(() => {
  whoAmI.mockReset();
  vi.spyOn(console, "warn").mockImplementation(() => {});
});

describe("champAuteur", () => {
  it("lie l'activite a l'utilisateur renvoye par WhoAmI", async () => {
    whoAmI.mockResolvedValue({ success: true, data: { UserId: "abc" } });
    const { champAuteur } = await chargerModule();
    expect(await champAuteur()).toEqual({ "gk_AuteurId@odata.bind": "/systemusers(abc)" });
  });

  it("n'appelle WhoAmI qu'une fois pour plusieurs activites", async () => {
    whoAmI.mockResolvedValue({ success: true, data: { UserId: "abc" } });
    const { champAuteur } = await chargerModule();
    await champAuteur();
    await champAuteur();
    expect(whoAmI).toHaveBeenCalledTimes(1);
  });

  it("n'empeche pas l'ecriture de l'activite si WhoAmI echoue, et reessaie ensuite", async () => {
    whoAmI.mockRejectedValueOnce(new Error("hors ligne"));
    whoAmI.mockResolvedValueOnce({ success: false, error: new Error("refuse") });
    whoAmI.mockResolvedValueOnce({ success: true, data: { UserId: "abc" } });
    const { champAuteur } = await chargerModule();
    expect(await champAuteur()).toEqual({});
    expect(await champAuteur()).toEqual({});
    expect(await champAuteur()).toEqual({ "gk_AuteurId@odata.bind": "/systemusers(abc)" });
  });
});
