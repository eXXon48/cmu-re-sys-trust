# cmu-re-sys-trust

**Current root certificates for TLS on the Mazda CMU150.** Stock firmware ships only a 2012
Mozilla bundle at `/etc/ssl/certs/cacert.pem`, and not at the paths TLS clients look for:
libcurl expects `/etc/ssl/certs/ca-certificates.crt`, the stock OpenSSL 1.0.1u expects
`/usr/lib/ssl/cert.pem`. Neither exists, and modern roots (e.g. ISRG Root X1) are missing.

This package installs curl's extract of the Mozilla CA bundle at both standard paths
(two identical copies: the Store cannot place symlinks yet). The stock `cacert.pem` is
left untouched. Any daemon, in any language, then verifies certificates "like a browser".

Certificate validity also needs a real clock: install `cmu-re-sys-time` too (the USB stick
installs both together with the Revised Store).

## Install / revert

Install or uninstall it in the Revised Store. No restart needed. Uninstalling removes both copies.

## Refreshing the roots

```sh
sh tools/update-bundle.sh    # downloads https://curl.se/ca/cacert.pem, checks its sha256
```

It rewrites both payload copies, `pkg/payload/certs/ca-certificates.crt` and
`pkg/payload/certs/cert.pem`. Run `sh tools/check-bundle.sh`, commit both, and tag a new release.

## Build

```sh
sh tools/mkpkg.sh <version> <path/to/rvp-pack> cmu-re-sys-trust-<version>.rvp
```

`rvp-pack` comes from the Revised Store repo. Releases: push a `vN` tag; CI packs the `.rvp`
and attaches it to the GitHub release.

## License

The certificate bundle is from Mozilla via curl, under the Mozilla Public License 2.0. The
rest: not chosen yet (TBD); until a license is added, no reuse rights are granted.
