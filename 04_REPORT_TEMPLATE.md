# YWH Report Template

Copy this per finding. Fill every field. A report that triage can reproduce in under two
minutes gets accepted; one they have to guess at gets closed. Keep it factual — no hype.

---

## Title
`[Bug class] on [asset] allows [impact]`
> e.g. `IDOR on /api/v2/invoices/{id} allows any authenticated user to read other users' invoices`

## Asset / Scope
- **Target:** `https://...` (must be an in-scope asset — quote the scope line it matches)
- **Program:** ...
- **Environment:** production / staging (as in scope)

## Vulnerability type
- **Class:** (IDOR / Subdomain takeover / Misconfig / Info disclosure / CORS / ...)
- **CWE:** e.g. CWE-639 (Authorization Bypass Through User-Controlled Key)

## Severity
- **CVSS 3.1 vector:** `CVSS:3.1/AV:N/AC:L/PR:L/UI:N/S:U/C:H/I:N/A:N`
- **Score / rating:** e.g. 6.5 (Medium)
- Justify each metric in one line so triage agrees with your score.

## Summary
2–3 sentences: what the bug is, where, and what an attacker gains. Plain language.

## Steps to Reproduce
Numbered, exact, copy-pasteable. Assume the reader has a fresh session.
1. Log in as User A (`accountA@...`). Note session cookie / token.
2. Navigate to ... / send request:
   ```http
   GET /api/v2/invoices/1042 HTTP/1.1
   Host: target.example.com
   Authorization: Bearer <A_token>
   ```
3. Observe your own invoice returned.
4. Now as User B, replay with A's object ID:
   ```http
   GET /api/v2/invoices/1042 HTTP/1.1
   Host: target.example.com
   Authorization: Bearer <B_token>
   ```
5. **Result:** B receives A's invoice (see PoC). Access control is missing.

## Proof of Concept
- Request/response pairs (redact real PII — show enough to prove, not to leak).
- Screenshots / short screen recording.
- For takeover: the claim state + your benign marker, timestamped.

## Impact
Concrete and honest. Who is affected, what data/actions, at what scale.
> "Any authenticated user can read arbitrary users' invoices (name, address, amount) by
> iterating the sequential `id`. ~N records enumerable. No auth-level restriction observed."

## Affected users / data
- Data types exposed: (PII? financial? credentials?)
- Number of records reachable / enumerable.

## Remediation
Actionable fix:
> "Enforce object-level authorization: verify the authenticated principal owns or is permitted
> to access the requested `invoice_id` before returning it. Prefer non-sequential identifiers."

## Supporting material
- Recon notes proving the asset is in scope.
- Any related endpoints affected by the same root cause.

---

### Pre-submit checklist
- [ ] Asset is **explicitly in scope**
- [ ] I stayed within ROE (no DoS, no real-PII exfiltration beyond proof, rate limits respected)
- [ ] Steps reproduce from scratch on a clean session
- [ ] Severity is honest and justified per metric
- [ ] PII in PoC is redacted
- [ ] Impact statement is concrete
- [ ] Remediation is actionable
- [ ] No duplicate (searched program's known issues where visible)
