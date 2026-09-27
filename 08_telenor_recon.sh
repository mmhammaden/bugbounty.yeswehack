#!/usr/bin/env bash
# Telenor Sweden — live-host triage pass.
# Run from the folder that has 06_TELENOR_TARGETS.txt.
# In scope via *.telenor.se (Low). Throttled + non-destructive. No DoS, respect ROE.
set -u

IN="06_TELENOR_TARGETS.txt"
OUT="telenor_recon"
mkdir -p "$OUT/shots"

echo "[*] Checking tools..."
for t in httpx gowitness subzy nuclei; do
  command -v "$t" >/dev/null 2>&1 || echo "    !! missing: $t  (see install notes at bottom)"
done

# 1) Which hosts are actually alive? Get status, title, tech, server, redirects.
#    -rl 20 = max 20 req/s (polite). -fr follows redirects.
echo "[*] Step 1: probing live hosts -> $OUT/live.txt"
httpx -l "$IN" \
  -sc -title -tech-detect -server -location -fr \
  -rl 20 -timeout 10 -retries 1 \
  -o "$OUT/httpx_full.txt"

# plain URL list of live hosts for the next steps
httpx -l "$IN" -silent -rl 20 -timeout 10 > "$OUT/live.txt"
echo "[*] live hosts: $(wc -l < "$OUT/live.txt")"

# 2) Screenshot every live host so you can eyeball logins / panels / staging banners.
echo "[*] Step 2: screenshots -> $OUT/shots/"
gowitness scan file -f "$OUT/live.txt" --screenshot-path "$OUT/shots/" --write-db 2>/dev/null \
  || cat "$OUT/live.txt" | gowitness scan file -f - --screenshot-path "$OUT/shots/"

# 3) Subdomain-takeover detection across ALL candidates (not just live).
#    NOTE: a hit here is NOT reportable until you actually claim it with a benign PoC.
echo "[*] Step 3: takeover check -> $OUT/takeover.txt"
subzy run --targets "$IN" --hide_fails 2>/dev/null | tee "$OUT/takeover_subzy.txt"
nuclei -l "$IN" -t http/takeovers/ -rl 20 -o "$OUT/takeover_nuclei.txt" -stats 2>/dev/null

# 4) Non-destructive exposure / misconfig sweep on LIVE hosts only.
#    Bare info-disclosure won't pay here — treat hits as leads to escalate, not reports.
echo "[*] Step 4: exposure/misconfig sweep -> $OUT/nuclei_exposures.txt"
nuclei -l "$OUT/live.txt" \
  -t http/exposures/ -t http/misconfiguration/ -t http/cves/ \
  -severity low,medium,high,critical \
  -rl 20 -o "$OUT/nuclei_exposures.txt" -stats 2>/dev/null

echo
echo "[✓] Done. Look at:"
echo "    $OUT/httpx_full.txt      (status/title/tech — find logins, APIs, panels)"
echo "    $OUT/shots/              (open in browser / gowitness report)"
echo "    $OUT/takeover_*.txt      (claim + benign PoC before reporting)"
echo "    $OUT/nuclei_exposures.txt (escalate to real impact before reporting)"
echo
echo "Next: pick self-service portals/APIs showing a login or API response and run the"
echo "two-account IDOR playbook from 03_BUG_CLASSES.md."
echo
echo "--- install notes (Kali) ---"
echo "  go install github.com/projectdiscovery/httpx/cmd/httpx@latest"
echo "  go install github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest && nuclei -update-templates"
echo "  go install github.com/sensepost/gowitness@latest"
echo "  go install github.com/PentestPad/subzy@latest"
echo "  (add \$HOME/go/bin to PATH; dnsx optional: .../dnsx/cmd/dnsx@latest)"
