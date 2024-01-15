{{/*
Expand the name of the chart.
*/}}
{{- define "cloud-signals.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 57 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 57 chars because some Kubernetes name fields are limited to 63 (by the DNS naming spec),
and we're going to add a cloud provider suffix (-s3/-gcs/-azure)
If release name contains chart name it will be used as a full name.
*/}}
{{- define "fusion.cloud-signals.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 57 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 57 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 57 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "cloud-signals.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 57 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "fusion.cloud-signals.labels" -}}
helm.sh/chart: {{ include "cloud-signals.chart" . }}
{{ include "cloud-signals.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "cloud-signals.selectorLabels" -}}
app.kubernetes.io/name: {{ include "cloud-signals.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "cloud-signals.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "cloud-signals.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
  Create service name for the job-launcher
*/}}
{{- define "fusion.cloud-signals.serviceName" -}}
{{- printf "cloud-signals" -}}
{{- end -}}

{{/*
Define the service name for zookeeper
*/}}
{{- define "fusion.cloud-signals.zkService" -}}
{{- if .Values.zkService -}}
{{- printf "%s" .Values.zkService -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name "zookeeper" -}}
{{- end -}}
{{- end -}}

{{/*
Define the kubernetes namespace variable
*/}}
{{- define "fusion.cloud-signals.kubeNamespace" -}}
{{- if .Values.namespaceOverride -}}
{{- printf "%s" .Values.namespaceOverride -}}
{{- else -}}
{{- printf "%s" .Release.Namespace -}}
{{- end -}}
{{- end -}}

{{/*
Define the admin url for kafka broker
*/}}
{{- define "fusion.cloud-signals.kafkaSvcUrl" -}}
{{- $tlsEnabled := ( eq ( include "fusion.tls.enabled" . ) "true" ) }}
{{- if .Values.global -}}
{{- if .Values.global.kafkaSvcUrl -}}
{{- printf "%s" .Values.global.kafkaSvcUrl -}}
{{- end -}}
{{- end -}}
{{- if .Values.kafkaSvcUrl -}}
{{- printf "%s" .Values.kafkaSvcUrl -}}
{{- end -}}
{{- end -}}
