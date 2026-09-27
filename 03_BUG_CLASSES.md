# High-ROI Bug Classes for a First Bounty

These are ordered by accept-rate-for-effort for beginners. Test only in-scope assets.

---

## 1. IDOR / Broken Access Control  ⭐ best first-bounty ROI
**What:** The app trusts a client-supplied identifier without checking you own the object.

**How to find it:**
- Create two test accounts (A and B) where the program allows it.
- As A, capture requests with object references: `/api/invoice/1042`, `?user_id=555`,
  `/orders/abc123`, GUIDs, base64/hashids.
- Replay them as B (swap A's session for B's). If B sees A's data → IDOR.
- Also try: incrementing/decrementing IDs, changing IDs in JSON bodies, swapping IDs in
  multi-step flows, and methods the UI doesn't expose (`PUT`/`DELETE`).

**Impact to state:** whose data is exposed, is it PII, can you modify/delete, scale of records.

**Why triage likes it:** clear, reproducible, obvious impact. Classic medium.

---

## 2. Subdomain Takeover  ⭐ pure recon, high accept rate
**What:** A DNS record (usually CNAME) points to a cloud service resource that no longer
exists, so you can claim it and serve content from their subdomain.

**How to find it:**
- From recon, find subdomains with CNAMEs to third-party services.
- Look for "not found / no such bucket / no such app" fingerprints on the target service.
- Confirm the resource is genuinely unclaimed. **Prove control minimally** — a benign marker
  page or the service's default claim state. Do **not** host anything harmful.

**Impact to state:** phishing on a trusted domain, cookie theft scope, brand damage.

---

## 3. Security Misconfiguration  ⭐ fast, common on forgotten hosts
Hunt these on staging/dev/old subdomains from recon:
- Exposed `/.git/` directory → source code disclosure
- Exposed `/.env`, config files, backups (`.bak`, `.old`, `.zip`)
- Open `/actuator`, `/swagger`, `/graphql` introspection, debug consoles
- Directory listing enabled
- Default credentials on admin panels (only if in-scope and allowed)
- Verbose stack traces leaking internal paths/versions

**Impact to state:** what exactly is exposed and what an attacker does with it.

---

## 4. Sensitive Information Disclosure
- API keys / tokens in JS bundles or responses (report; don't abuse them)
- Internal hostnames, IPs, employee data in responses/headers
- `.map` source maps exposing full frontend source
- PII returned to unauthorized users

**Note:** a *key* alone is often low unless you can show it's live and impactful. State the
impact honestly — inflated severity gets reports downgraded or closed.

---

## 5. CORS Misconfiguration
- `Access-Control-Allow-Origin` reflects arbitrary origin **with**
  `Allow-Credentials: true` → cross-origin data theft. Demonstrate with a PoC page.

---

## 6. Authentication / Logic flaws (once you're comfortable)
- Password reset token leakage or reuse
- Missing rate limiting on sensitive actions (often low, sometimes medium)
- OTP/2FA bypass, race conditions in redemption flows

---

## Severity honesty
Use the program's CVSS/reward table. **Report the true impact.** Over-claiming is the #1
reason first reports get closed as "informative." A well-scoped medium beats a rejected
"critical" every time.
