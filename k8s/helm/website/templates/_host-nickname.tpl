{{- define "hostNickname" -}}
{{- $configmap := (lookup "v1" "ConfigMap" (.Namespace | default "default") (.Name | default "host-metadata")) }}

{{- $hostNickname := "tharja" }}
{{- if $configmap }}
{{- $hostNickname = get $configmap.data "hostNickname" }}
{{- end }}
{{- $hostNickname }}
{{- end }}