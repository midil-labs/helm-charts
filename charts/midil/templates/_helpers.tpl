{{/*
Expand the name of the service.
*/}}
{{- define "app.name" -}}
{{- default .Values.serviceName .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "app.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Values.serviceName .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "midil.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "app.labels" -}}
helm.sh/chart: {{ include "midil.chart" . }}
{{ include "app.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: {{ .Values.platform }}-platform
{{ .Values.platform }}.midil.io/service: {{ .Values.serviceName }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "app.selectorLabels" -}}
app.kubernetes.io/name: {{ include "app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "app.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "app.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Recursively flattens nested values into __ separated keys
Usage: {{ include "midil.flatten" (dict "root" "MIDIL" "section" "API" "values" .Values.midil.config.api) }}
*/}}
{{- define "midil.flatten" -}}
{{- $root := .root -}}
{{- $section := .section -}}
{{- $values := .values -}}
{{- range $key, $value := $values }}
  {{- $fullKey := printf "%s__%s" $section ($key | upper) -}}
  {{- if kindIs "map" $value }}
    {{- include "midil.flatten" (dict "root" $root "section" $fullKey "values" $value) }}
  {{- else }}
{{ $root }}__{{ $fullKey }}: {{ $value | quote }}
  {{- end }}
{{- end }}
{{- end }}

