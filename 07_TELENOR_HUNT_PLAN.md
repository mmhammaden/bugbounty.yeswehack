# Telenor Sweden — Prioritized Hunt Plan

> **STOP — read this first.** These hosts came from passive recon (subfinder + crt.sh).
> They are *candidates*, not confirmed scope. Before you send a single active request to
> any host below, open the live Telenor Sweden program page on YWH and confirm the host
> (or a wildcard that covers it) is **explicitly in scope**. Anything not covered → do not touch.
> Customer CPE / broadband subdomains (`bbcust.*`, PTR ranges like `84-218-*`, `62-127-*`,
> `212-105-*`, `213-150-*`, `213-242-*`) are **out of scope** and were already excluded.

The 106 hosts fall into tiers by likely payoff-for-effort. Work top-down.

---

## Tier 1 — Test/staging/dev of production apps  ⭐ hunt these first
Non-prod copies of real apps are the #1 source of first bounties: weaker auth, debug on,
old code, sometimes shared prod data. Screenshot every one, then probe.

**Auth / identity (non-prod):**
- `signin-test.telenor.se`, `signin-sandbox.telenor.se`
- `profile-test.telenor.se`, `profile-test.ingress1-exp-tst-1.aws1.telenor.se`
- `curity-runtime.ingress1-exp-tst-1.aws1.telenor.se` (Curity = OAuth/OIDC server — misconfig gold)

**Self-service portals (non-prod) → IDOR / broken access control:**
- `mina-tst01/02/03.telenor.se` (test copies of "Mina Sidor" = My Pages)
- `foretag-webon-test/stage/test1/stage1.telenor.se` (business web-onboarding)
- `mtw-pwa-stage/test.telenor.se`

**APIs (non-prod) → IDOR, missing auth, verbose errors:**
- `apis-dev/test/test01/test02.telenor.se`, `apitest-at.telenor.se`, `apitest1.telenor.se`
- `api-app-sit/sat.telenor.se`, `b2bapis-test.telenor.se`
- `eone-dev/fut/sit/sat.telenor.se`

**Other non-prod services:**
- `charging-test`, `m2m-test`, `esim-test`, `safezone-test`, `spd-test`
- `tv-stage/test`, `portal-stb-test.tv`
- `onex.preprod`, `tsefspanel-pp`, `tseflowscape-pp`

---

## Tier 2 — Production self-service + APIs  → IDOR / access control
Higher competition (many eyes) but object-ID endpoints still yield mediums.
- `mitt.telenor.se`, `minasidor.telenor.se` (My Pages — invoices, orders, profile)
- `mittforetag.telenor.se` + `mittforetag1-4` (business self-service)
- `foretagsportalen`, `foretagsabonnemang`, `businesscenter`, `kundpanel`, `kundentre`
- `api.telenor.se`, `api-app`, `apis`, `b2bapis`, `telcoapi`
- `customers.telenor.se`, `online.telenor.se`, `enterprise.telenor.se`

**How:** two test accounts (if allowed), capture every request carrying an ID
(`/invoice/1042`, `?customerId=`, GUIDs, order refs), replay as the other account.
See `03_BUG_CLASSES.md` §1.

---

## Tier 3 — Admin / internal / back-office panels  → auth bypass, exposure
Often forgotten, sometimes exposed to the internet with weak/no auth. Confirm scope carefully —
some internal hosts may be explicitly out of scope.
- `merchportal`, `supplierconnect`, `responsadmin`, `vaxelportalen` (PBX/switchboard admin)
- `kundpanel`, `mboss`, `tsefspanel`, `sitetracker`, `mdm`, `mdp`
- `keyconcept.int`, `ninja.int`, `sitelog.int`, `ksintranet` (`.int` = internal — likely OOS, check)
- `statistik`, `statstyr`, `mymeter`

**Do not brute-force credentials.** Look for: no-auth access, default landing pages, exposed
config, verbose errors, IDOR once authenticated legitimately.

---

## Tier 4 — Misconfig / info-disclosure sweep  → fast, low-medium
Run content discovery on the live hosts from Tiers 1–3 for:
`/.git/`, `/.env`, `/actuator`, `/swagger`, `/graphql` (introspection), `.map` files,
directory listing, backups (`.bak/.old/.zip`).
Highest odds on dev/test hosts and:
- `developer.telenor.se`, `telcoapi`, `apis-dev` (API docs/keys leakage)
- `webdav.telenor.se` (WebDAV misconfig / open write?)
- `lagring` (storage), `mediearkivet`, `publish`, `workspace`, `workspacebackup`
- `eone*`, `onex*`

---

## Tier 5 — Subdomain takeover sweep  → pure recon, run across ALL 106
Dangling DNS is the cleanest first bounty. Run takeover detection on the entire list —
prime suspects are old/renamed services:
- `kampanj` (campaign), `aktivering`, `aktiverabredband`, `registreratv` (one-off campaign hosts)
- `spd-test`, `safezone-test`, `mymeter`, `mediearkivet`, decommissioned `eone*`
- Anything resolving to a CNAME at a cloud provider with a "not found" fingerprint.

---

## The commands (run only against confirmed-in-scope hosts)

`dnsx` wasn't installed on your box — install it or skip it (subfinder already gave you names;
httpx will resolve as it probes).

```bash
# 0. install dnsx if you want live-resolution filtering (optional)
go install github.com/projectdiscovery/dnsx/cmd/dnsx@latest

# 1. find which candidates are actually live (probe, get titles + tech + status)
httpx -l 06_TELENOR_TARGETS.txt -sc -title -tech-detect -td -server -o live_hosts.txt

# 2. screenshot every live host to triage visually (fastest way to spot panels/staging)
httpx -l 06_TELENOR_TARGETS.txt -silent | gowitness scan file -f - --screenshot-path shots/
#    (or: cat live_hosts.txt | aquatone)

# 3. subdomain-takeover sweep across the whole list
subzy run --targets 06_TELENOR_TARGETS.txt
nuclei -l 06_TELENOR_TARGETS.txt -t http/takeovers/ -stats

# 4. safe misconfig / exposure sweep (NON-destructive templates only — respect ROE)
nuclei -l live_hosts.txt -t http/exposures/ -t http/misconfiguration/ -severity low,medium,high -rl 20

# 5. content discovery on a specific interesting host (mind rate limits + ROE)
ffuf -u https://apis-dev.telenor.se/FUZZ -w /path/to/seclists/Discovery/Web-Content/common.txt -mc 200,204,301,302,401,403 -rate 20
```

**ROE reminders:** `-rl 20` / `-rate 20` throttle to be polite. No DoS, no aggressive fuzzing
where forbidden, no touching out-of-scope hosts "just to check." If the program bans automated
scanners, skip nuclei/ffuf and do it by hand.

---

## Suggested first session (2–3 hrs)
1. Confirm scope on the live YWH page. Cross off any Tier host not covered.
2. `httpx` + `gowitness` the full 106 → skim screenshots.
3. Run the takeover sweep (Tier 5) — cheapest possible bounty, runs while you look at shots.
4. Pick 2–3 non-prod portals/APIs from Tier 1 that showed a login or API response.
5. Register test account(s) if allowed; start the IDOR playbook from `03_BUG_CLASSES.md`.
6. Log everything in `05_SUBMISSION_TRACKER.md` as you go.
