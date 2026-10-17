{{ define "htpasswd.generateHtpasswd" }}
{{- $values := .Values }}
{{- $release := .Release }}
{{- range $secretRef := .Values.secrets }}
{{- $secret := lookup "v1" "Secret" (default $release.Namespace $secretRef.namespace) $secretRef.name }}
{{- if not $secret }}
{{- $mode := default "sync" (get $values "mode") -}}
{{- if eq $mode "template" }}
{{- $secret = dict "data" (dict "username" "templateuser" "password" "templatepassword") }}
{{- else }}
{{- fail (printf "Secret '%s' not found in namespace '%s'" $secretRef.name (default $release.Namespace $secretRef.namespace)) }}
{{- end }}
{{- end }}
{{ htpasswd ($secret.data.username | b64dec) ($secret.data.password | b64dec) }}
{{- end }}
{{ end}}