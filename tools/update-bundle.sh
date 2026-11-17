#!/bin/sh
# Refresh pkg/payload/certs/ca-certificates.crt from curl's Mozilla extract, checked against
# its published sha256. Commit the result: every refresh is a reviewable diff.
set -eu
cd "$(dirname "$0")/.."
url=https://curl.se/ca/cacert.pem
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
curl -fsSL -o "$tmp/cacert.pem" "$url"
curl -fsSL -o "$tmp/cacert.pem.sha256" "$url.sha256"
want=$(cut -d' ' -f1 "$tmp/cacert.pem.sha256")
got=$(sha256sum "$tmp/cacert.pem" | cut -d' ' -f1)
[ -n "$want" ] && [ "$want" = "$got" ] || { echo "sha256 mismatch: want $want got $got" >&2; exit 1; }
sh tools/check-bundle.sh "$tmp/cacert.pem"
cp "$tmp/cacert.pem" pkg/payload/certs/ca-certificates.crt
echo "bundle updated: $(sed -n 's/^## Certificate data from Mozilla as of: //p' pkg/payload/certs/ca-certificates.crt)"
