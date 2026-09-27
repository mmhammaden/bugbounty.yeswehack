# Recon Checklist

Recon is where first bounties are won. The goal: map the full attack surface, then find the
**forgotten assets** nobody else bothered to look at. Stay strictly in scope.

> Rule: if an asset isn't clearly covered by the program's scope/wildcard, don't touch it.

## Phase 1 — Passive (no packets to the target)
- [ ] Read scope + out-of-scope + ROE end to end. Write down the wildcard(s).
- [ ] Enumerate subdomains from passive sources (certificate transparency logs, public
      DNS datasets, search engines). Tools: `subfinder`, `amass` (passive mode), crt.sh.
- [ ] Pull historical URLs from web archives / URL datasets (`gau`, `waybackurls`).
- [ ] Look for the org's public code footprint: exposed repos, package registries, paste
      sites — for leaked endpoints/keys (report responsibly, don't use creds).
- [ ] Note the tech stack (headers, frameworks, cloud provider) — informs which bugs to hunt.

## Phase 2 — Light active (in scope only)
- [ ] Resolve all discovered subdomains; keep the live ones.
- [ ] Port/service sweep on in-scope hosts (respect rate limits and ROE).
- [ ] Screenshot every live host to triage fast (`gowitness`/`aquatone`). Look for:
      login panels, admin interfaces, default pages, error pages, staging/dev banners.
- [ ] Content discovery on interesting hosts: `/admin`, `/api`, `/.git/`, `/backup`,
      `/swagger`, `/graphql`, `/.env`, `/actuator`. (Wordlists: seclists.)
- [ ] Crawl the main app; extract JS files and grep them for endpoints, API paths, keys,
      internal hostnames.

## Phase 3 — Prioritize targets
Rank what you found by "likely-forgotten + likely-vulnerable":
1. **Dangling DNS / unclaimed cloud resources** → subdomain takeover
2. **Staging / dev / old-version subdomains** → weak auth, debug endpoints, IDOR
3. **APIs with object IDs in the path** → IDOR / broken access control
4. **Exposed config/metadata** (`.git`, `.env`, `swagger`, `actuator`) → info disclosure
5. **Login/registration flows** → auth logic bugs

## Recon hygiene
- Set a custom User-Agent that identifies you as a researcher if the program requests it.
- Respect rate limits. Getting IP-banned mid-hunt loses you the program.
- Keep a running asset log (host, tech, interesting paths, notes) — feeds the tracker.
- Never run destructive or DoS-style tooling. Never touch out-of-scope assets "just to check."

## What "done" looks like
You have a list of live in-scope hosts, each tagged with tech + interesting endpoints, and a
shortlist of 5–15 targets ranked by the priorities above. Now go hunt `03_BUG_CLASSES.md`.
