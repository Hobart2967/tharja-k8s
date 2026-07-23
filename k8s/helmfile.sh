#!/bin/bash
echo helmfile -f helmfile.host.yaml.gotmpl -e sidra $* && echo helmfile $*
helmfile -f helmfile.host.yaml.gotmpl -e sidra $* && helmfile $*
