{{/*
Common labels
*/}}
{{- define "lab12.mylabels.v1" -}}
labels:
  env: {{ .Values.env }}
  app: {{ .Release.Name }}
{{- end }}
{{- define "lab12.mylabels.v2" -}}
env: {{ .Values.env }}
app: {{ .Release.Name }}
{{- end }}