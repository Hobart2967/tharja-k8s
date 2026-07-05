{{ define "hostname-by-dns" -}}
{{- $dnszone := (lookup "bindy.firestoned.io/v1beta1" "DNSZone" "default" .zone) }}
{{- if not $dnszone }}
  {{- $dnszone = (dict "apiVersion" "bindy.firestoned.io/v1beta1" "kind" "DNSZone" "metadata" (dict "name" .zone "namespace" "default") "spec" (dict "zoneName" .zone)) }}
{{- end }}
{{- $hostname := $dnszone.spec.zoneName }}
{{- if not (eq .name "@") }}
  {{- $hostname = printf "%s.%s" .name $hostname }}
{{- else }}
  {{- $hostname = printf "%s" $hostname }}
{{- end }}
{{- $hostname }}
{{- end }}
