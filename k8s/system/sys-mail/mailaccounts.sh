#!/bin/sh
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <namespace>"
  exit 1
fi

echo "Extracting consumer values from secrets in namespace $1"

mkdir -p .tmp

YQ_VERSION=$(yq --version 2>/dev/null || true)
if echo "$YQ_VERSION" | grep -qi "mikefarah"; then
  CONFIGMAPS=$(kubectl -n "$1" get secrets -o yaml | yq eval '.items
    | map(select(.metadata.annotations."hobart2967.github.io/mail-account" == "true"))
    | map({"username": (.data.username | @base64d), "password": .data.password, "aliases": (.data.aliases | @base64d | from_yaml)})
    | {"mailboxes": .}' -)
else
  echo "This script requires mikefarah yq for parsing secret YAML strings"
  exit 1
fi

#echo $CONFIGMAPS
echo "$CONFIGMAPS" > .tmp/users.yaml