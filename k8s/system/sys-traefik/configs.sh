#!/bin/sh
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <namespace>"
  exit 1
fi

echo "Extracting consumer values from configmap in namespace $1"

mkdir -p .tmp

YQ_VERSION=$(yq --version 2>/dev/null || true)
if echo "$YQ_VERSION" | grep -qi "mikefarah"; then
  CONFIGMAPS=$(kubectl -n "$1" get configmap -o yaml | yq eval '.items
    | map(select(.metadata.annotations."hobart2967.github.io/traefik-config" == "true"))
    | map(.data.config | from_yaml)
    | .[] as $item ireduce ({}; . *+ $item)' -)
else
  echo "This script requires mikefarah yq for parsing config YAML strings"
  exit 1
fi

#echo $CONFIGMAPS
printf '%s\n' "$CONFIGMAPS" | sed '1{/^[[:space:]]*$/d;}' > .tmp/configs.yaml