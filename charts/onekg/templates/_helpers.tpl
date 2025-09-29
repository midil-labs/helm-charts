{{/*
Expand the name of the service.
*/}}
{{- define "onekg.name" -}}
{{- default .Values.serviceName .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "onekg.fullname" -}}
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
{{- define "onekg.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "onekg.labels" -}}
helm.sh/chart: {{ include "onekg.chart" . }}
{{ include "onekg.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: onekg-platform
service.onekg.io/name: {{ .Values.serviceName }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "onekg.selectorLabels" -}}
app.kubernetes.io/name: {{ include "onekg.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "onekg.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "onekg.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Health check path with service prefix
*/}}
{{- define "onekg.healthPath" -}}
{{- if .Values.probes.enabled }}
{{- .Values.probes.liveness.path }}
{{- else }}
{{- $path := .Values.ingress.path | default "/" }}
{{- if hasSuffix "/" $path }}
{{- printf "%shealth" $path }}
{{- else }}
{{- printf "%s/health" $path }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Recursively flattens nested values into __ separated keys
Usage: {{ include "onekg.flatten" (dict "root" "MIDIL" "section" "API" "values" .Values.midil.config.api) }}
*/}}
{{- define "onekg.flatten" -}}
{{- $root := .root -}}
{{- $section := .section -}}
{{- $values := .values -}}
{{- range $key, $value := $values }}
  {{- $fullKey := printf "%s__%s" $section ($key | upper) -}}
  {{- if kindIs "map" $value }}
    {{- include "onekg.flatten" (dict "root" $root "section" $fullKey "values" $value) }}
  {{- else }}
{{ $root }}__{{ $fullKey }}: {{ $value | quote }}
  {{- end }}
{{- end }}
{{- end }}

