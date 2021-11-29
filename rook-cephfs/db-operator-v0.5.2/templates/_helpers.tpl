{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "db-operator.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "db-operator.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "db-operator.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "db-operator.serviceAccountName" -}}
{{- if .Values.rbac.create -}}
    {{ include "db-operator.fullname" . }}
{{- else -}}
    {{ default "default" .Values.rbac.serviceAccountName }}
{{- end -}}
{{- end -}}

{{- define "db-operator.raftlist" -}}
{{- $fullname := include "db-operator.fullname" . -}}
{{- $replicas := int .Values.replicas -}}
{{- range $i := until $replicas -}}
{{ $fullname }}-{{ $i }}-svc{{- if lt $i (sub $replicas 1) }},{{ end }}
{{- end -}}
{{- end -}}

{{- define "db-operator.orc-config-name" -}}
{{ include "db-operator.fullname" . }}-orc
{{- end -}}

{{- define "db-operator.orc-secret-name" -}}
{{- if .Values.orchestrator.secretName -}}
  {{ .Values.orchestrator.secretName }}
{{- else -}}
  {{ include "db-operator.fullname" . }}-orc
{{- end -}}
{{- end -}}

{{- define "db-operator.orc-service-name" -}}
{{ include "db-operator.fullname" . }}-orc
{{- end -}}

{{/*
Common labels
*/}}
{{- define "db-operator.labels" -}}
app.kubernetes.io/name: {{ include "db-operator.name" . }}
helm.sh/chart: {{ include "db-operator.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}