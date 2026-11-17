#!/bin/sh
# usage: check-bundle.sh [bundle]  -> every PEM block parses, more than 100 certificates
set -eu
f=${1:-$(dirname "$0")/../pkg/payload/certs/ca-certificates.crt}
n=$(openssl crl2pkcs7 -nocrl -certfile "$f" | openssl pkcs7 -print_certs -noout | grep -c '^subject=')
blocks=$(grep -c -- '-----BEGIN CERTIFICATE-----' "$f")
[ "$n" = "$blocks" ] || { echo "parsed $n of $blocks certificates" >&2; exit 1; }
[ "$n" -gt 100 ] || { echo "only $n certificates" >&2; exit 1; }
echo "bundle ok: $n certificates"
# the two payload copies must stay identical (only when checking the repo's own payload)
if [ $# -eq 0 ]; then
    d=$(dirname "$0")/../pkg/payload/certs
    cmp "$d/ca-certificates.crt" "$d/cert.pem"
fi
