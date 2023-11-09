{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "fusion.job-rest-server.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "fusion.job-rest-server.fullname" -}}
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
{{- define "fusion.job-rest-server.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
  Define the labels that should be applied to all resources in the chart
*/}}
{{- define "fusion.job-rest-server.labels" -}}
helm.sh/chart: "{{ include "fusion.job-rest-server.chart" . }}"
app.kubernetes.io/name: "{{ template "fusion.job-rest-server.name" . }}"
app.kubernetes.io/managed-by: "{{ .Release.Service }}"
app.kubernetes.io/instance: "{{ .Release.Name }}"
app.kubernetes.io/version: "{{ .Chart.AppVersion }}"
app.kubernetes.io/component: "job-rest-server"
app.kubernetes.io/part-of: "fusion"
{{- end -}}

{{/*
Define the Spring Profile
*/}}
{{- define "fusion.job-rest-server.springProfs" -}}
{{- if .Values.springProfilesOverride -}}
{{- printf "%s" .Values.springProfilesOverride -}}
{{- else -}}
{{- if .Values.datadog.enabled }}
{{- printf "%s,datadog" .Values.springProfiles -}}
{{- else -}}
{{- printf "%s" .Values.springProfiles -}}
{{- end -}}
{{- end -}}
{{- end -}}
