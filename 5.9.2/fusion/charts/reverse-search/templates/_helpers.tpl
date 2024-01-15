{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "reverse-search.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "reverse-search.fullname" -}}
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
Define the name of the headless service for reverse-search
*/}}
{{- define "reverse-search.headless-service-name" -}}
{{- printf "%s-%s" (include "reverse-search.fullname" .) "headless" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Define the name of the client service for reverse-search
*/}}
{{- define "reverse-search.service-name" -}}
{{- printf "%s-%s" (include "reverse-search.fullname" .) "svc" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Define the name of the reverse-search exporter
*/}}
{{- define "reverse-search.exporter-name" -}}
{{- printf "%s-%s" (include "reverse-search.fullname" .) "exporter" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Define the reverse-search exporter configmap
*/}}
{{- define "reverse-search.exporter-configmap-name" -}}
{{- printf "%s-%s" (include "reverse-search.exporter-name" .) "config" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "reverse-search.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
  Define the name of the reverse-search PVC
*/}}
{{- define "reverse-search.pvc-name" -}}
{{ printf "%s-%s" (include "reverse-search.fullname" .) "pvc" | trunc 63 | trimSuffix "-"  }}
{{- end -}}

{{/*
  Define the name of the reverse-search.xml configmap
*/}}
{{- define "reverse-search.configmap-name" -}}
{{- printf "%s-%s" (include "reverse-search.fullname" .) "kafka-props" | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/*
Define the server urls to kafka brokers
*/}}
{{- define "fusion.reverse-search.kafkaBrokers" -}}
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
  Define the labels that should be applied to all resources in the chart
*/}}
{{- define "reverse-search.common.labels" -}}
app.kubernetes.io/name: {{ include "reverse-search.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ include "reverse-search.chart" . }}
{{- end -}}
