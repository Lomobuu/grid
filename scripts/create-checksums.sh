#!/usr/bin/env bash
#
# Generates _checksums.sha256 for a KA Terraform ISO package, in the same
# format the vendor produces:
#
#   <sha256>  ./relative/path
#
# Usage:
#   ./create-checksums.sh vendor-package/KA-Terraform-ISO-6.30.3582.zip
#   ./create-checksums.sh path/to/extracted/package
#
# Given a zip, the manifest is generated from its contents and written back
# into the zip at the root, which is where the workflow expects to find it.
#
set -euo pipefail

MANIFEST="_checksums.sha256"

target="${1:-}"

if [[ -z "$target" ]]; then
  echo "Usage: $0 <package-dir|package.zip>" >&2
  exit 1
fi

generate() {
  cd "$1"

  # Written outside the package, so find cannot hash the file being written.
  local tmp
  tmp="$(mktemp)"

  # Paths come out as ./relative/path, sorted, manifest itself excluded.
  find . -type f ! -name "$MANIFEST" -print0 \
    | LC_ALL=C sort -z \
    | xargs -0 sha256sum > "$tmp"

  mv "$tmp" "$MANIFEST"
  chmod 644 "$MANIFEST"

  # Prove the manifest we just wrote actually passes --check.
  sha256sum --check --quiet "$MANIFEST"

  echo "Hashed $(wc -l < "$MANIFEST") files"
}

if [[ -d "$target" ]]; then
  ( generate "$target" )
  echo "Wrote $target/$MANIFEST"

elif [[ -f "$target" && "$target" == *.zip ]]; then
  zip_path="$(cd "$(dirname "$target")" && pwd)/$(basename "$target")"

  work="$(mktemp -d)"
  trap 'rm -rf "$work"' EXIT

  unzip -q "$zip_path" -d "$work"
  ( generate "$work" )

  # Adds the manifest, or replaces it if the zip already had one.
  ( cd "$work" && zip -q "$zip_path" "$MANIFEST" )

  echo "Added $MANIFEST to $zip_path"

else
  echo "Not a directory or a .zip file: $target" >&2
  exit 1
fi
