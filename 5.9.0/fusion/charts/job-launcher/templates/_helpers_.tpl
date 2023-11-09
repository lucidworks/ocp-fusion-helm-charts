{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "fusion.job-launcher.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "fusion.job-launcher.fullname" -}}
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
{{- define "fusion.job-launcher.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
  Create service name for the job-launcher
*/}}
{{- define "fusion.job-launcher.serviceName" -}}
{{- printf "job-launcher" -}}
{{- end -}}

{{/*
Define the service name for zookeeper
*/}}
{{- define "fusion.job-launcher.zkService" -}}
{{- if .Values.zkService -}}
{{- printf "%s" .Values.zkService -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name "zookeeper" -}}
{{- end -}}
{{- end -}}

{{/*
  Define the labels that should be applied to all resources in the chart
*/}}
{{- define "fusion.job-launcher.labels" -}}
helm.sh/chart: "{{ include "fusion.job-launcher.chart" . }}"
app.kubernetes.io/name: "{{ template "fusion.job-launcher.name" . }}"
app.kubernetes.io/managed-by: "{{ .Release.Service }}"
app.kubernetes.io/instance: "{{ .Release.Name }}"
app.kubernetes.io/version: "{{ .Chart.AppVersion }}"
app.kubernetes.io/component: "job-launcher"
app.kubernetes.io/part-of: "fusion"
{{- if .Values.labels -}}
{{- range $key, $value := .Values.labels }}
{{ $key }}: {{ $value | quote }}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
  Define the custome labels that should be applied to spark resources in the chart
*/}}
{{- define "fusion.job-launcher.customlabels" -}}
{{- if .Values.labels -}}
{{- $list := list -}}
{{- range $key, $value := .Values.labels }}
    {{- $list = printf "%s:%s" $key $value | append $list -}}
{{- end -}}
{{ join ", " $list }}
{{- end -}}
{{- end -}}

{{/*
Define the Spring Profile
*/}}
{{- define "fusion.job-launcher.springProfs" -}}
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
