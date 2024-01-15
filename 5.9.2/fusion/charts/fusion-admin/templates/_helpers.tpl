{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "fusion.fusion-admin.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "fusion.fusion-admin.fullname" -}}
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
{{- define "fusion.fusion-admin.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "fusion.fusion-admin.serviceName" -}}
{{- printf "admin" -}}
{{- end -}}

{{/*
  Define the labels that should be applied to all resources in the chart
*/}}
{{- define "fusion.fusion-admin.labels" -}}
helm.sh/chart: "{{ include "fusion.fusion-admin.chart" . }}"
app.kubernetes.io/name: "{{ template "fusion.fusion-admin.name" . }}"
app.kubernetes.io/managed-by: "{{ .Release.Service }}"
app.kubernetes.io/instance: "{{ .Release.Name }}"
app.kubernetes.io/version: "{{ .Chart.AppVersion }}"
app.kubernetes.io/component: "fusion-admin"
app.kubernetes.io/part-of: "fusion"
{{- end -}}

{{/*
Define the server urls to kafka brokers
*/}}
{{- define "fusion.fusion-admin.kafkaBrokers" -}}
    {{- $tlsEnabled := ( eq ( include "fusion.tls.enabled" . ) "true" ) }}
    {{- $kafkaReplicas:="" -}}
    {{- if .Values.global -}}
        {{- if .Values.global.kafkaReplicaCount -}}
            {{- $kafkaReplicas = .Values.global.kafkaReplicaCount -}}
        {{- else -}}
            {{- $kafkaReplicas = .Values.kafkaReplicaCount -}}
        {{- end -}}
    {{- else -}}
        {{- $kafkaReplicas = .Values.kafkaReplicaCount -}}
    {{- end -}}

    {{- if .Values.global -}}
        {{- if .Values.global.kafka -}}
            {{- if .Values.global.kafka.bootstrapServers -}}
                {{- printf "%s" .Values.global.kafka.bootstrapServers -}}
            {{- end -}}
        {{- else if .Values.kafka.bootstrapServers -}}
            {{- printf "%s" .Values.kafka.bootstrapServers -}}
        {{- else if .Values.global.kafkaSvcUrl -}}
            {{- printf "%s" .Values.global.kafkaSvcUrl -}}
        {{- else if .Values.kafkaSvcUrl -}}
            {{- printf "%s" .Values.kafkaSvcUrl -}}
        {{- else -}}
            {{- range $i := until ( int ( $kafkaReplicas )) -}}
            {{- if ne $i 0 }},{{ end }}{{- printf "%s-kafka-%d.%s-%s:%s" $.Release.Name $i $.Release.Name "kafka-headless" $.Values.kafka.servicePort -}}
            {{- end -}}
        {{- end -}}
    {{- else -}}
        {{- range $i := until ( int ( $kafkaReplicas )) -}}
        {{- if ne $i 0 }},{{ end }}{{- printf "%s-kafka-%d.%s-%s:%s" $.Release.Name $i $.Release.Name "kafka-headless" $.Values.kafka.servicePort -}}
        {{- end -}}
    {{- end -}}
{{- end -}}


{{/*
Define the kubernetes namespace variable
*/}}
{{- define "fusion.fusion-admin.kubeNamespace" -}}
{{- if .Values.namespaceOverride -}}
{{- printf "%s" .Values.namespaceOverride -}}
{{- else -}}
{{- printf "%s" .Release.Namespace -}}
{{- end -}}
{{- end -}}
