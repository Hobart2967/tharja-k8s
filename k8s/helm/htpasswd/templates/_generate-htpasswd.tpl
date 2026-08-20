{{ define "htpasswd.generateHtpasswd" }}
{{- $release := .Release }}
{{- range $secretRef := .Values.secrets }}
{{- $secret := lookup "v1" "Secret" (default $release.Namespace $secretRef.namespace) $secretRef.name }}
{{- if not $secret }}
{{- fail (printf "Secret '%s' not found in namespace '%s'" $secretRef.name (default $release.Namespace $secretRef.namespace)) }}
{{- end }}
{{ htpasswd ($secret.data.username | b64dec) ($secret.data.password | b64dec) }}
{{- end }}
{{ end}}