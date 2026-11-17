# CoNote

Students write private notes for each class; CoNote AI turns the class's combined notes into a
draft summary; a teacher approves it; students read the approved version.

This repository is a monorepo (npm workspaces). Each role gets its own app, and the apps share
one backend and a set of packages:

| Folder              | Package            | What it is                                                |
| ------------------- | ------------------ | --------------------------------------------------------- |
| `apps/student`      | `@conote/student`  | The student portal: an installable web app (built, M1–M5) |
| `apps/admin`        | `@conote/admin`    | The admin console                                         |
| `apps/teacher`      | `@conote/teacher`  | The teacher portal                                        |
| `packages/ui`       | `@conote/ui`       | Design tokens, Tailwind theme, UI primitives, form fields |
| `packages/portal`   | `@conote/portal`   | Sign-in, guards and frame shared by admin and teacher     |
| `packages/supabase` | `@conote/supabase` | Supabase client, sessions and error mapping               |
| `packages/domain`   | `@conote/domain`   | Shared roles and statuses                                 |
| `packages/core`     | `@conote/core`     | Errors, safe redirects, environment checks, reporting     |
| `packages/testing`  | `@conote/testing`  | Test-only helpers shared by every app                     |

Taking the project over? Start with [`docs/HANDOVER.md`](docs/HANDOVER.md). Progress:
[`docs/MILESTONES.md`](docs/MILESTONES.md) (student) and
[`docs/admin/MILESTONES.md`](docs/admin/MILESTONES.md) (admin).

## Quick start

Requires **Node 22.22 or newer** (see `.nvmrc`).

```bash
npm ci                                                 # installs every app and package
cp apps/student/.env.example apps/student/.env.local   # optional: the defaults use demo data
npm run dev                                            # the student app, http://localhost:5173
npm run dev:admin                                      # the admin console, http://localhost:5174/admin
```

**Student app:** sign in with **any valid email and any password**, or either OAuth button. You
are signed in as the demo student. Demo data lives in your browser's storage.

**Admin console:** sign in as `admin@conote.example` with the password `password1`. The demo
teacher and student accounts (`teacher@` and `student@conote.example`, same password) are turned
away, which shows the admin-only guard.

## Scripts

Run from the repository root. Lint, format, type check, tests, `build`, `size` and `e2e` cover
every app and package; `dev` and `preview` run the student app (`npm run dev:admin` for the
console, or add `-w @conote/<app>` to run any script in one app).

| Command                        | What it does                                                |
| ------------------------------ | ----------------------------------------------------------- |
| `npm run dev`                  | Start the dev server                                        |
| `npm test`                     | Unit and component tests in watch mode                      |
| `npm test -- --run --coverage` | Run tests once with the coverage floor (as CI does)         |
| `npm run e2e`                  | Build, serve with production headers, run Playwright        |
| `npm run lint`                 | ESLint, zero warnings allowed                               |
| `npm run format`               | Format everything with Prettier                             |
| `npm run typecheck`            | TypeScript project build, no output                         |
| `npm run build`                | Production build of every app into `apps/<app>/dist/`       |
| `npm run size`                 | Check the initial JavaScript against the 250 KB gzip budget |

A pre-commit hook (Husky + lint-staged) formats, lints and runs related tests on staged files.

**Playwright on a machine with its own Chromium:** set `PW_CHROMIUM_PATH` to the browser
executable to skip Playwright's download.

## Environment variables

| Variable                 | Default | Notes                                                   |
| ------------------------ | ------- | ------------------------------------------------------- |
| `VITE_DATA_SOURCE`       | `mock`  | `mock` (demo data) or `supabase` (the real backend)     |
| `VITE_SUPABASE_URL`      |         | Only for `supabase`. Must be `https`.                   |
| `VITE_SUPABASE_ANON_KEY` |         | Only for `supabase`. Never put a service-role key here. |

Variables are validated at startup (`apps/student/src/lib/env.ts`). Vite bakes them in at build time, so a
change needs a rebuild or redeploy.

## Folder guide

Inside `apps/student/`:

```
src/
  app/          router table, providers, service factory (the only file that picks mock vs Supabase)
  pages/        one folder per route; each page is lazy-loaded
  layouts/      public, auth and portal shells; sidebar, bottom bar, top bar
  components/
    common/     shared app components (SafeHtml, PlaceholderPage, RouteErrorBoundary, ...)
  features/auth AuthProvider, useAuth, route guards
  services/     service interfaces, ServicesProvider, contract tests
    mock/       demo implementation
    supabase/   placeholder until the backend stage
  lib/          pure helpers: routes, env, errors, sanitising, safe redirects, storage
  types/        domain types
  test/         test setup, factories, render helpers, axe helper
e2e/            Playwright tests
public/         icons, iPhone launch images, favicon
scripts/        icon and launch-image generator
```

The shared UI primitives live in `packages/ui/src/components/`, and the docs in `docs/` at the
root.

Import rules between these folders are enforced by ESLint
([`docs/ENGINEERING_STANDARDS.md`](docs/ENGINEERING_STANDARDS.md) section 3.1).

## Switching to Supabase (backend stage)

1. Implement each interface in `apps/student/src/services/types.ts` under
   `apps/student/src/services/supabase/`.
2. Run the existing contract suites (`apps/student/src/services/contracts/`) against it.
3. Return the new implementation from `createSupabaseServices()`.
4. Set `VITE_DATA_SOURCE=supabase` plus the two Supabase variables.

No page or hook changes should be needed. If one is, the interface was wrong.

## Deployment

Vercel, configured by the root `vercel.json`: it builds the student app
(`npm run build -w @conote/student`, output in `apps/student/dist`), adds a rewrite so client-side
routes survive a refresh, and sends the security headers from the engineering standards. `npm run e2e` serves the
build with the same headers, so a policy that breaks the app fails locally and in CI first.

## Documentation

- [`docs/HANDOVER.md`](docs/HANDOVER.md): taking over the project: accounts, running, changing, deploying, what is left
- [`docs/REQUIREMENTS.md`](docs/REQUIREMENTS.md): scope, routes, requirement IDs, data model, decisions log
- [`docs/MILESTONES.md`](docs/MILESTONES.md): build order, CI and deployment
- [`docs/USER_FLOWS.md`](docs/USER_FLOWS.md): sitemap, user flows, user journeys
- [`docs/ENGINEERING_STANDARDS.md`](docs/ENGINEERING_STANDARDS.md): testing, architecture, security, review


 # CoNote Milestone 3 CLA 02 CYB 319
 We actually knocked out the heaviest lifting for **Milestone 3: Integrate Application and Dependency Security Scanning** during our previous troubleshooting! By adding Trivy to the pipeline, catching the `lodash` vulnerability (which satisfied SEC-01), and removing it, you successfully demonstrated a blocked pipeline and remediation.

However, looking at the official project document you just shared, we have two quick things left to fully complete Milestone 3:

1. **Preserving Reports:** The requirements state you must "Generate and preserve scan reports" and "Store security reports as pipeline artifacts".


2. **Investigation Questions:** You need to answer 10 theoretical questions about software vulnerabilities for your final report.



Here is how we fulfill both of those right now.

### 1. Store Security Reports as Pipeline Artifacts

We need to update your Trivy job to save its findings into a file and upload it so you can download it later as audit evidence.

1. **Update the Trivy Workflow:** Modify ci.yml.
Open your `.github/workflows/ci.yml` file and update your `security-scan` job (the Trivy one) to output a JSON report and upload it. Replace your existing Trivy step with these two steps:

```yaml
  - name: Run Trivy vulnerability scanner
    uses: aquasecurity/trivy-action@master
    with:
      scan-type: 'fs'
      scan-ref: '.'
      format: 'json'
      output: 'trivy-report.json'
      exit-code: '1'
      ignore-unfixed: true
      vuln-type: 'os,library'
      severity: 'CRITICAL,HIGH'

  - name: Upload Trivy Report Artifact
    uses: actions/upload-artifact@v4
    if: always() # Ensures the report uploads even if Trivy fails the build
    with:
      name: trivy-security-report
      path: trivy-report.json

```


2. **Commit and Verify:** Check the Actions tab.
Commit this change and push it to GitHub.
*Verification:* Once the pipeline finishes, go to the pipeline summary page in GitHub Actions. Scroll to the bottom, and you will see a section called **Artifacts** containing your `trivy-security-report`. Take a screenshot of this for your Milestone 3 deliverables!


---

### 2. Milestone 3 Investigation Questions

1. **What is a software vulnerability?**
A flaw, weakness, or misconfiguration in software code or architecture that an attacker can exploit to compromise the confidentiality, integrity, or availability of the system.


2. **Difference between a vulnerability in your code and a third-party dependency?**
A code vulnerability is a logical flaw you wrote yourself. A third-party vulnerability exists in an external library (like `lodash`) that you imported; you don't control the code, so you must wait for the maintainer to release a patch or find an alternative.


3. **What does a CVE represent?**
Common Vulnerabilities and Exposures. It is a standardized, publicly disclosed identifier (e.g., CVE-2021-44228) used to track specific cybersecurity vulnerabilities across the industry.


4. **Does a HIGH vulnerability always mean the application can be exploited?**
No. Exploitability depends heavily on environmental context. For example, a vulnerable library might be installed, but if the specific vulnerable function is never called by your application, or if it is blocked by a Web Application Firewall (WAF), it cannot be actively exploited.


5. **Should every vulnerability automatically block a production release?**
No. Blocking on every low-severity issue would halt development. Only vulnerabilities that breach defined risk thresholds (e.g., CRITICAL, actively exploitable, and fixable) should block a release.


6. **How can false positives affect development productivity?**
They cause "alert fatigue." If scanners constantly block builds for non-issues, developers waste hours investigating them, which builds frustration, slows down delivery, and leads to teams ignoring real security alerts.


7. **What is a vulnerability exception, and who should authorize it?**
It is a formal acceptance of a specific risk for a set period (e.g., accepting a vulnerability because a patch doesn't exist yet, but a compensating control is in place). It should be authorized by security leadership or a risk management committee, not the developer who wrote the code.


8. **Why is scanning only the source code insufficient?**
Because the final deployed application includes much more than source code. It relies on infrastructure configurations, base container images, and runtime packages that can introduce their own severe vulnerabilities entirely independent of the source code.


9. **How should security reports be retained and reviewed?**
They should be stored as immutable artifacts directly in the CI/CD platform (which we just configured) and ideally forwarded to a centralized security dashboard for long-term auditability and compliance tracking.


10. **What happens when a new vulnerability is discovered in a dependency after the application has already been deployed?**
The CI/CD pipeline won't catch it because the code has already passed. The organization must rely on Continuous Cloud Security Posture Management (CSPM) and Cloud Workload Protection Platforms (CWPP) to continuously scan running environments and registry images, triggering an incident response process to patch and redeploy.



          