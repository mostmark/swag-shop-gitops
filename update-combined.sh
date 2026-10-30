#!/usr/bin/env bash
# Regenerates swag-shop.yaml from the files in manifests/. Run it after changing, adding or removing a manifest.
set -euo pipefail
cd "$(dirname "$0")"
export LC_ALL=C

{
  echo "# All manifests from manifests/ in one file. Deploy with: oc apply -f swag-shop.yaml"
  echo "# or paste into Import YAML in the OpenShift console."
  for file in manifests/*.yaml; do
    echo "---"
    echo "# Source: $file"
    cat "$file"
  done
} >swag-shop.yaml

echo "Wrote swag-shop.yaml from $(ls manifests/*.yaml | wc -l | tr -d ' ') manifests"
