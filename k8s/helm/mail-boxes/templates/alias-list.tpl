{{- define "alias-list" }}
{{- $foundAlias := false }}
{{- range $id, $aliasField := .fields }}
{{- if $id | hasPrefix "alias-" }}
{{- $foundAlias = true }}
- {{ $aliasField.value | quote }}
{{- end }}
{{- end }}
{{- if not $foundAlias }}
[]
{{- end }}
{{- end }}