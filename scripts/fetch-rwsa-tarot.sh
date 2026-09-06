#!/usr/bin/env bash
# Download the full-resolution RWSa (Pam-A Rider-Waite-Smith) scans from steve-p.org.
# Source page: https://steve-p.org/cards/RWSa.html
# Thumbnails at small/sm_<code>.webp map to full-size pix/<code>.png (see the site's
# commonnew.js dispbig handler). ~80 images, ~3 MB each. Resumable: existing files
# are skipped, so re-running only fetches what's missing.
#
# Licensing: the 1909 deck is public domain. These are the site owner's own
# cleaned-up scans, and the page asks for can-I-use requests by e-mail --
# permission for this 80-image set was confirmed by the project owner on
# 2026-07-15. See decision D1 in
# docs/superpowers/plans/2026-07-15-campaigns-shared-tarot-roadmap.md and the
# permissionBasis field in static/tarot/rwsa/tarot-art.json, which is the
# record of record.
#
# Only these particular scans carry a permission claim; the 1909 artwork is
# public domain independently of them, which is why the source collection is
# deliberately swappable (scripts/tarot-art/source-map.mjs, COLLECTION).

set -euo pipefail

BASE="https://steve-p.org/cards"
DEST="$(cd "$(dirname "$0")/.." && pwd)/assets-src/tarot/rwsa"

mkdir -p "$DEST"

echo "Fetching card list from $BASE/RWSa.html ..."
codes=$(curl -fsS "$BASE/RWSa.html" | grep -o 'sm_RWSa-[^"]*\.webp' | sed 's/^sm_//; s/\.webp$//' | sort -u)

total=$(wc -l <<<"$codes" | tr -d ' ')
echo "Found $total cards. Downloading to $DEST"

n=0
for code in $codes; do
    n=$((n + 1))
    out="$DEST/$code.png"
    if [[ -s "$out" ]]; then
        echo "[$n/$total] $code.png already present, skipping"
        continue
    fi
    echo "[$n/$total] $code.png"
    curl -fsS --retry 3 -o "$out" "$BASE/pix/$code.png"
    sleep 1
done

echo "Done. $(find "$DEST" -name '*.png' | wc -l | tr -d ' ') files in $DEST"
