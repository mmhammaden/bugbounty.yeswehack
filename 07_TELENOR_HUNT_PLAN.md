# Telenor Sweden — Prioritized Hunt Plan (scope-gated 2026-09-27)

Scope confirmed against the live YWH program. Key facts that shape everything below:

- **`*.telenor.se` is in scope at LOW asset value.** So *almost every one of your 106 hosts is
  in scope* — at minimum the Low tier. That's the floor.
- **Four HIGH-value families** override that floor: `signin.telenor.se`, `profile.telenor.se`,
  `*.apis.telenor.se`, `*.api-app.telenor.se`. Bugs here pay the most (€200–€6,000).
- **Two MEDIUM-value families:** `*.mittforetag.telenor.se`, `*.foretagsportalen.telenor.se`.
- **Non-prod pays LOW no matter what.** Any uat/qual/pprd/dev/sit/sat/stage/sandbox/test/preprod
  host is rewarded at the **Low grid** even if it sits under a High wildcard — *unless the same
  bug reproduces on production*. A bug found on both prod and non-prod is rewarded **once**.
- **Report within 24h of discovery**, only via yeswehack.com. Submission costs 2 credits,
  refunded if valid (you have 7 → don't burn them on weak reports).
- **This program is heavily hunted:** 1,968 reports, ~36 last week. Prod common-bugs are
  picked over → your edge is *forgotten/non-prod hosts* and *business-logic/IDOR* nobody else
  bothered to chain. Triage is fast (<1 day first response), which is good for learning.

> Out of scope from the exclusion list — do NOT test: `*.bbcust`, `*.cust`, `*.sme.telenor.se`,
> `admin-stage.tv.telenor.se`, `*.telenor.com`, anything customer/third-party-owned, and mobile
> services not reachable from the internet. **None of your 106 are on the explicit blocklist**,
> but see the "verify ownership" flags in Tier 3.

---

## What actually pays here — filter every finding through this

**Qualifying (go after these):** RCE, SQLi/SSTI/injection, LFI/RFI/XXE/SSRF, XSS,
CSRF *with real impact*, **IDOR**, CORS *with real impact*, horizontal/vertical privesc,
**business logic errors**, auth bypass / broken access control, exposed secrets on *in-scope*
assets, cache poisoning / race conditions, clickjacking *with impact*, open redirect to
non-Telenor domains, user enumeration (only if not by-design).

**NON-qualifying — don't waste a submission (these get closed):**
- Info disclosure *without direct security impact* (stack traces, path/dir listing, versions,
  IP disclosure) — so a bare `/.git` version banner or directory listing alone **won't pay**.
- **Subdomain takeover without a full working PoC** — you must actually claim it (benign marker).
- Missing rate-limit / brute-force / captcha, TLS/SSL, HSTS, SPF/DKIM/DMARC.
- Self-XSS, CSRF with low impact, misconfigured API key *without exploitable PoC*.
- Blind SSRF with no direct impact (DNS pingback only).

Translation for your first bounty: **IDOR / broken access control / business logic on the
self-service portals and APIs** is the sweet spot. Info-disclosure and takeover only count if
you carry them all the way to demonstrated impact.

---

## Tier 1 — HIGH-value, non-prod first  ⭐ best effort-to-acceptance
Non-prod caps reward at Low, but acceptance is what a *first* bounty needs, and these are far
less contested. Screenshot, then hunt IDOR/access-control/auth flaws.

**Auth / identity:**
- `signin.telenor.se` (prod, HIGH tier), `signin-test`, `signin-sandbox`
- `profile.telenor.se` (prod, HIGH tier), `profile-test`
- `curity-runtime.ingress1-exp-tst-1.aws1.telenor.se` — Curity OIDC/OAuth server; hunt
  token/scope/redirect_uri misconfig, IDOR on user endpoints.
- `idp.uc.telenor.se`, `idpsso.uc.telenor.se`, `entitlement.telenor.se`

**Core APIs (HIGH family + Low-tier siblings):**
- HIGH: `apis.telenor.se`, `api-app.telenor.se`
- Low-tier siblings (still in scope via `*.telenor.se`): `apis-dev/test/test01/test02`,
  `apitest-at`, `apitest1`, `api-app-sit/sat`, `b2bapis`, `b2bapis-test`, `api`, `telcoapi`
- `developer.telenor.se` — API docs; harvest endpoint list + look for leaked keys with a PoC.

**How:** enumerate API object references (`/customer/{id}`, `/invoice/{id}`, GUIDs, order refs),
authenticate legitimately with your own test account, replay another ID → IDOR. Try
undocumented methods (`PUT`/`DELETE`), missing auth on internal endpoints, JWT scope tampering.

---

## Tier 2 — MEDIUM-value self-service portals  → IDOR / privesc / business logic
- `mittforetag.telenor.se` + `mittforetag1-4` (MEDIUM family — business self-service)
- `foretagsportalen.telenor.se` (MEDIUM family)
- `foretag-webon-test/stage/test1/stage1` (business onboarding — Low tier, non-prod, less picked-over)
- Prod My-Pages (Low tier via `*.telenor.se`, but data-rich): `mitt`, `minasidor`,
  `foretagsabonnemang`, `businesscenter`, `kundpanel`, `kundentre`, `customers`, `online`,
  `enterprise`
- Non-prod My-Pages copies (Low, less contested): `mina-tst01/02/03`, `mtw-pwa-stage/test`

**Business-logic angles that pay here:** change plan/subscription for another account, view
another company's users/invoices, escalate a normal user to admin within a company tenant,
manipulate order/activation flows (`aktivering`, `aktiverabredband`, `registreratv`).

---

## Tier 3 — Admin / back-office / internal  → auth bypass, broken access control
Forgotten panels sometimes sit exposed with weak/no auth. **Verify ownership first** — a couple
here look like third-party SaaS and would be out of scope:
- Likely Telenor: `vaxelportalen` (switchboard admin), `responsadmin`, `merchportal`,
  `supplierconnect`, `kundpanel`, `mboss`, `statistik`, `statstyr`, `mdm`, `mdp`
- ⚠️ **Check ownership before testing** — look third-party-owned (likely OOS if so):
  `sitetracker` (SiteTracker SaaS), `tsefspanel`, `tsefspanel-pp`, `tseflowscape`,
  `tseflowscape-pp` (Flowscape), `mymeter`
- ⚠️ `.int` internal hosts — only in scope if publicly reachable *and* Telenor-owned:
  `keyconcept.int`, `ninja.int`, `sitelog.int`, `ksintranet`

No credential brute-force (non-qualifying anyway). Look for no-auth access, auth bypass,
IDOR/privesc after legitimate login.

---

## Tier 4 — Exposure sweep — ONLY if you can show real impact
Bare info-disclosure is non-qualifying, so a hit here only pays if you escalate it:
exposed secret → **prove it's live and grants access to an in-scope asset**; source map/`.git`
→ **use it to find a real vuln**; open `/actuator` or GraphQL introspection → **reach a
sensitive action**. Best hosts to sweep: `developer`, `telcoapi`, `apis-dev`, `webdav`
(WebDAV write?), `lagring`, `mediearkivet`, `publish`, `workspace`, `workspacebackup`,
`eone*`, `onex`/`onex.preprod`.

---

## Tier 5 — Subdomain takeover — full PoC required or it's rejected
Program explicitly rejects takeover *without a full working PoC*. So: detect dangling CNAMEs,
then actually claim the resource with a benign marker page before reporting. Prime suspects
(old/campaign/one-off hosts): `kampanj`, `aktivering`, `aktiverabredband`, `registreratv`,
`spd-test`, `safezone-test`, `mediearkivet`, decommissioned `eone*`, `portal-stb-test.tv`.

---

## The commands (run only against the hosts above — all in scope via `*.telenor.se`)

```bash
go install github.com/projectdiscovery/dnsx/cmd/dnsx@latest   # optional; you were missing it

# 1. which candidates are live + titles/tech/status
httpx -l 06_TELENOR_TARGETS.txt -sc -title -tech-detect -server -o live_hosts.txt

# 2. screenshot everything to triage panels/staging fast
httpx -l 06_TELENOR_TARGETS.txt -silent | gowitness scan file -f - --screenshot-path shots/

# 3. takeover detection (then MANUALLY claim + benign PoC before reporting)
subzy run --targets 06_TELENOR_TARGETS.txt
nuclei -l 06_TELENOR_TARGETS.txt -t http/takeovers/ -stats

# 4. non-destructive exposure sweep (respect ROE; escalate hits to real impact)
nuclei -l live_hosts.txt -t http/exposures/ -t http/misconfiguration/ -severity low,medium,high -rl 20

# 5. content discovery on one interesting host (throttled)
ffuf -u https://apis-dev.telenor.se/FUZZ -w SecLists/Discovery/Web-Content/common.txt -mc 200,204,301,302,401,403 -rate 20
```

ROE: no DoS, respect rate limits (`-rl/-rate 20`), no data destruction/modification, redact
PII in PoCs, verify-only on any credentials you find.

---

## Recommended first session (aim: one accepted Low)
1. `httpx` + `gowitness` the full 106; skim screenshots for logins/panels/API pages.
2. Kick off the takeover sweep in the background (Tier 5) while you look.
3. Register test account(s) on a self-service portal (`mina-tst0X` or `mittforetag` if allowed).
4. Run the **IDOR / access-control playbook** (`03_BUG_CLASSES.md` §1) on that portal's API —
   two accounts, swap object IDs. This is your highest-probability first accept.
5. The moment you have a reproducible finding: write it up with `04_REPORT_TEMPLATE.md`,
   redact PII, and submit **within 24h**. Log it in `05_SUBMISSION_TRACKER.md`.
