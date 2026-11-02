# ATIP Request Tracker

*[Version française](README.md)*

> A fictitious internal application that lets a federal department's Access to Information and Privacy (ATIP) office receive, track, and process access requests, in compliance with the legal 30-day deadline and extensions — built entirely on Microsoft Power Platform.

🚧 **Status: in active development.** The Dataverse schema, demo data, all 4 screens of the React code app, and the 3 Power Automate flows (including extension approval) are functional and tested. Track progress in [docs/progression.md](docs/progression.md) (French).

## Roadmap

- [x] Dataverse schema (tables, columns, relationships) and fictitious demo data
- [x] React code app (Power Apps): 4 screens, bilingualism, Vitest, Playwright and axe-core tests
- [x] Power Automate flows: acknowledgement, duplicate-free daily reminders, extension approval
- [x] ALM backup: unpacked solution, demo data and deployment settings under version control
- [ ] Security: Agent and Manager roles, server-side validation plug-in
- [ ] Reproducible deployment and GitHub Actions
- [ ] Manual accessibility testing (screen reader, contrast)
- [ ] Final documentation, demo video, online demo mode

## Features

- Track an ATIP request (Access to Information / Privacy) from intake to closure
- Automatic calculation of the legal 30-day deadline, with extension handling
- Dashboard: counters by status, overdue requests or requests due within 5 days
- Timestamped activity log per request
- Automatic reminders to agents via a daily scheduled flow
- Fully bilingual FR/EN application (no hardcoded text), WCAG 2.1 AA compliant
- Least-privilege security roles: ATIP Agent and ATIP Manager

## Preview

![Dashboard in English: counts by status and overdue requests](docs/images/06-app-tableau-de-bord-en.png)

More screenshots (French interface) in the [user guide](docs/guide-utilisateur.md).

## Architecture

```mermaid
graph TD
    Agent["ATIP Agent"]
    Mgr["ATIP Manager"]

    subgraph System["ATIP Tracker (Power Platform)"]
        App["React code app<br/>(Power Apps)"]
        DV[("Microsoft Dataverse")]
        PA["Power Automate<br/>(cloud flows)"]
    end

    Agent -->|"creates, processes, closes"| App
    Mgr -->|"dashboard, approves"| App
    App <--> DV
    PA <--> DV
```

Full diagrams (context, components, request lifecycle): [docs/architecture.md](docs/architecture.md)

## Stack

- **Microsoft Dataverse** (developer environment, Power Apps Developer Plan)
- **Power Apps code app** — React + TypeScript + Vite, hosted and governed by Power Platform (Microsoft Entra authentication, connectors, DLP)
- **React Router**, React context for FR/EN bilingualism
- **Playwright + axe-core** — automated WCAG 2.1 AA accessibility tests
- **GC Design System (GCDS)** — via npm, bundled locally (see [ADR 0002](docs/adr/0002-canvas-vs-code-app.md))
- **Power Automate** — cloud flows
- **Power Platform solution** (`gk` prefix) + **Power Platform CLI** (`pac`) and **Power Apps CLI** (`pa`) for ALM
- **GitHub Actions** (`microsoft/powerplatform-actions`) for checking and packaging
- **Documentation**: Markdown + Mermaid, published with MkDocs Material

## Documentation

| Document | Content |
|---|---|
| [Architecture](docs/architecture.md) | Context, component, and lifecycle diagrams |
| [Data model](docs/modele-donnees.md) | ERD and Dataverse data dictionary |
| [Power Automate flows](docs/flux.md) | Triggers, steps, error handling |
| [Security](docs/securite.md) | Roles, least privilege, classification |
| [Accessibility](docs/accessibilite.md) | WCAG 2.1 AA / EN 301 549 checklist |
| [Official languages](docs/langues-officielles.md) | Bilingual FR/EN approach |
| [ALM](docs/alm.md) | Solution, environments, variables, pipeline |
| [Installation](docs/installation.md) | Deploying the solution to another environment |
| [User guide](docs/guide-utilisateur.md) | Using the application, with screenshots |
| [ADR](docs/adr/) | Architecture decisions, one per option considered |
| [Case study](docs/portfolio-etude-de-cas.md) | Problem, role, solution, results, lessons learned |
| [Interview prep](docs/entrevue.md) | 60-second pitch and likely questions |

## GC compliance

As a demonstration project, this repository reflects the following principles:

- **Government of Canada Digital Standard**: user-centred, iterative design, open by default (public repository, documented decisions).
- **Official languages**: fully bilingual French/English interface, no hardcoded text in the application.
- **Accessibility**: targets WCAG 2.1 AA / EN 301 549 — see [docs/accessibilite.md](docs/accessibilite.md).
- **Access to Information Act**: the 30-day processing deadline and extension mechanism are faithfully reproduced in the data model and flows.

## ⚠️ Licensing

This project uses a **Power Apps code app** (preview). The [Power Apps Developer Plan](https://learn.microsoft.com/power-platform/developer/plan) fully covers development and testing. In production, **end users** need a **Power Apps Premium** license (or pay-as-you-go access, an App Pass, or auto-claim) — see [docs/securite.md](docs/securite.md).

## ⚠️ Fictitious data

All data used in this project (requests, names, emails, request subjects) is **entirely fictitious** and generated for demonstration purposes only. No real data or real personal information is used.

## Author

**Gween Kangah** — [gweenkangah.pro](https://gweenkangah.pro) — [github.com/itsGween](https://github.com/itsGween)
