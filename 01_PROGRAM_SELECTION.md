# Program Selection Scorecard

Picking the right program is 50% of the battle for a first bounty. Score each candidate
before investing time. On YWH, use the program directory filters to build your shortlist.

## Score each program 0–2 on each row (max 20). Hunt anything scoring 14+.

| Criteria | 0 | 1 | 2 |
|---|---|---|---|
| **Scope size** | Single host | Few hosts | Wildcard `*.domain` / large |
| **Rewards low/medium?** | Critical only | Medium+ | Low + medium rewarded |
| **Program age** | Years old, mature | Established | New or recently expanded |
| **Response/triage speed** | Slow / unknown | Average | Fast, active triage |
| **Asset type comfort** | Unfamiliar stack | Some familiarity | Web app you know well |
| **Competition signals** | Huge crowd | Moderate | Low activity / niche |
| **Out-of-scope clarity** | Vague | Some detail | Crystal clear ROE |
| **Recent scope changes** | None | Minor | New assets added recently |
| **VDP vs paid** | VDP only | Mixed | Paid, reasonable amounts |
| **Special conditions** | Heavy restrictions | Some | Few restrictions |

## Why these matter for a *first* bounty
- **Wildcard scope** = forgotten subdomains, staging servers, old apps. This is where
  beginners find real bugs mature hunters skipped.
- **Rewards lows** = your realistic finds (info disclosure, minor IDOR, misconfig) actually pay.
- **New / recently expanded scope** = less picked-over. A subdomain added last month has been
  seen by far fewer eyes than the main app.
- **Fast triage** = you learn faster and get paid faster.

## Green flags
- `*.example.com` wildcard in scope
- "We reward low severity" or a full CVSS-based reward table
- Recently added assets in the changelog
- Program says they accept subdomain takeover, IDOR, misconfig

## Red flags (skip for your first ones)
- "Only P1/P2 (critical/high) rewarded"
- Scope is a single hardened marketing site
- Massive researcher leaderboard (fully mined)
- Vague out-of-scope that could get your report closed as invalid

## Always read before testing
- The **scope** and **out-of-scope** lists — memorize them.
- **Rules of engagement**: rate limits, no-DoS, no social engineering, no automated
  scanners if forbidden, test-account rules, PII handling.
- **Reward table** so you target bug classes that actually pay.
