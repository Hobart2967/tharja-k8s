{{- define "stageDomain" -}}
{{- $hostNickname := include "hostNickname" (dict "Namespace" "default" "Name" "host-metadata") }}
{{- $domain := .DomainName }}
{{- if not (eq $hostNickname "tharja") }}
{{- $domain = (printf "%s.%s" $hostNickname .DomainName) }}
{{- end }}
{{- end }}