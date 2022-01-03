{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "fusion.fusion-indexing.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "fusion.fusion-indexing.fullname" -}}
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
{{- define "fusion.fusion-indexing.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "fusion.fusion-indexing.serviceName" -}}
{{- printf "indexing" -}}
{{- end -}}

{{/*
Define the admin service endpoint
*/}}
{{- define "fusion.fusion-indexing.adminServiceEndpoint" -}}
{{- if .Values.adminServiceEndpoint -}}
{{- printf "%s" .Values.adminServiceEndpoint -}}
{{- else -}}
{{- printf "admin:8765" -}}
{{- end -}}
{{- end -}}

{{/*
Define the service url for pulsar broker
*/}}
{{- define "fusion.fusion-indexing.pulsarServiceUrl" -}}
{{- $tlsEnabled := ( eq ( include "fusion.tls.enabled" . ) "true" ) }}
{{- if .Values.global -}}
{{- if .Values.global.pulsarServiceUrl -}}
{{- printf "%s" .Values.global.pulsarServiceUrl -}}
{{- end -}}
{{- end -}}
{{- if .Values.pulsarServiceUrl -}}
{{- printf "%s" .Values.pulsarServiceUrl -}}
{{- else -}}
{{- printf "%s://%s-pulsar-broker:%s" ( ternary "pulsar+ssl" "pulsar" $tlsEnabled  )  .Release.Name ( (ternary .Values.pulsarServiceTLSPort .Values.pulsarServicePort $tlsEnabled ) ) -}}
{{- end -}}
{{- end -}}

{{/*
Define the admin url for pulsar broker
*/}}
{{- define "fusion.fusion-indexing.pulsarAdminUrl" -}}
{{- $tlsEnabled := ( eq ( include "fusion.tls.enabled" . ) "true" ) }}
{{- if .Values.global -}}
{{- if .Values.global.pulsarAdminUrl -}}
{{- printf "%s" .Values.global.pulsarAdminUrl -}}
{{- end -}}
{{- end -}}
{{- if .Values.pulsarAdminUrl -}}
{{- printf "%s" .Values.pulsarAdminUrl -}}
{{- else -}}
{{- printf "%s://%s-pulsar-broker:%s" ( ternary "https" "http" $tlsEnabled  )  .Release.Name ( (ternary .Values.pulsarTLSPort .Values.pulsarPort $tlsEnabled ) ) -}}
{{- end -}}
{{- end -}}


{{/*
Define the kubernetes namespace variable
*/}}
{{- define "fusion.fusion-indexing.kubeNamespace" -}}
{{- if .Values.namespaceOverride -}}
{{- printf "%s" .Values.namespaceOverride -}}
{{- else -}}
{{- printf "%s" .Release.Namespace -}}
{{- end -}}
{{- end -}}

{{/*
Define the Spring Profile
*/}}
{{- define "fusion.fusion-indexing.springProfs" -}}
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

{{/*
Define the Datadog configuration
*/}}
{{- define "fusion.fusion-indexing.datadogHost" -}}
{{- if .Values.datadog.host -}}
{{- .Values.datadog.host -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name "datadog" -}}
{{- end -}}
{{- end -}}

{{/*
  Define the labels that should be applied to all resources in the chart
*/}}
{{- define "fusion.fusion-indexing.labels" -}}
helm.sh/chart: "{{ include "fusion.fusion-indexing.chart" . }}"
app.kubernetes.io/name: "{{ template "fusion.fusion-indexing.name" . }}"
app.kubernetes.io/managed-by: "{{ .Release.Service }}"
app.kubernetes.io/instance: "{{ .Release.Name }}"
app.kubernetes.io/version: "{{ .Chart.AppVersion }}"
app.kubernetes.io/component: "fusion-indexing"
app.kubernetes.io/part-of: "fusion"
{{- end -}}

{{- define "fusion.tikaServerUrl" -}}
{{- if .Values.tikaServerUrl -}}
{{- printf "%s" .Values.tikaServerUrl -}}
{{- else -}}
{{- printf "http://tikaserver:9998" -}}
{{- end -}}
{{- end -}}

{{- define "fusion.initContainers.checkIndexing" -}}
{{- $tlsEnabled := ( eq (include "fusion.tls.enabled" .) "true" ) -}}
- name: check-indexing
  image: {{ .Values.image.repository }}/check-fusion-dependency:v1.3.0
  imagePullPolicy: IfNotPresent
  securityContext:
    readOnlyRootFilesystem: true
    runAsNonRoot: true
    allowPrivilegeEscalation: false
    privileged: false
    runAsUser: {{ .Values.securityContext.runAsUser }}
  resources:
    requests:
      cpu: 200m
      memory: 32Mi
    limits:
      cpu: 200m
      memory: 32Mi
  args:
    - indexing
  env:
    - name: INDEXING_ENDPOINT
      value: {{ .Values.indexingEndpoint | default ( printf "%s://indexing" ( ternary "https" "http" $tlsEnabled ) ) }}
    - name: INDEXING_PORT
      value: {{ .Values.indexingPort | default 8765 | quote }}
    - name: CHECK_INTERVAL
      value: {{ .Values.indexingInitCheckInterval | default "5s" }}
    - name: CHECK_TIMEOUT
      value: {{ .Values.indexingInitCheckTimeout | default "2s" }}
    - name: TIMEOUT
      value: {{ .Values.indexingInitTimeout | default "2m" }}
{{- if $tlsEnabled }}
    - name: ADDITIONAL_CA_CERTIFICATE
      value: "/tls/ca.crt"
  volumeMounts:
    - name: keystore-volume
      mountPath: /tls
{{- end }}
{{- end -}}