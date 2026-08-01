#!/bin/sh
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <namespace>"
  exit 1
fi

echo "Extracting CrowdSec bouncer key from secret in namespace $1"

mkdir -p .tmp

YQ_VERSION=$(yq --version 2>/dev/null || true)
if echo "$YQ_VERSION" | grep -qi "mikefarah"; then
  API_KEY=$(kubectl -n "$1" get secret crowdsec-bouncer-key -o jsonpath='{.data.api-key}' 2>/dev/null | base64 -d)
else
  echo "This script requires mikefarah yq"
  API_KEY=$(kubectl -n "$1" get secret crowdsec-bouncer-key -o jsonpath='{.data.api-key}' 2>/dev/null | base64 -d)
fi

if [ -z "$API_KEY" ]; then
  echo "Error: crowdsec-bouncer-key secret not found or empty in namespace $1"
  echo "Create the secret via host-secrets (1Password entry: 'crowdsec-bouncer-key', field: 'api-key')"
  exit 1
fi

printf 'apiKey: "%s"\n' "$API_KEY" > .tmp/bouncer-key.yaml
