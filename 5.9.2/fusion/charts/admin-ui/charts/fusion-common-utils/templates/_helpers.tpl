{{/*
Return the target Kubernetes version
*/}}
{{- define "common.capabilities.kubeVersion" -}}
{{- if $.Values.global }}
    {{- if $.Values.global.kubeVersion }}
    {{- $.Values.global.kubeVersion -}}
    {{- else }}
    {{- default .Capabilities.KubeVersion.Version $.Values.kubeVersion -}}
    {{- end -}}
{{- else }}
{{- default .Capabilities.KubeVersion.Version $.Values.kubeVersion -}}
{{- end -}}
{{- end -}}
{{/*

Return the appropriate apiVersion for poddisruptionbudget.
*/}}
{{- define "common.capabilities.policy.apiVersion" -}}
{{- if semverCompare "<1.21-0" (include "common.capabilities.kubeVersion" .) -}}
{{- print "policy/v1beta1" -}}
{{- else -}}
{{- print "policy/v1" -}}
{{- end -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for cronjob.
*/}}
{{- define "common.capabilities.cronjob.apiVersion" -}}
{{- if semverCompare "<1.21-0" (include "common.capabilities.kubeVersion" .) -}}
{{- print "batch/v1beta1" -}}
{{- else -}}
{{- print "batch/v1" -}}
{{- end -}}
{{- end -}}


{{/*
Return the appropriate apiVersion for HorizontalPodAutoscaler.
*/}}
{{- define "common.capabilities.autoscaling.apiVersion" -}}
{{- if semverCompare "<1.23-0" (include "common.capabilities.kubeVersion" .) -}}
{{- if .beta2 -}}
{{- print "autoscaling/v2beta2" -}}
{{- else -}}
{{- print "autoscaling/v2beta1" -}}
{{- end -}}
{{- else -}}
{{- print "autoscaling/v2" -}}
{{- end -}}
{{- end -}}

{{- define "fusion.tls.enabled" -}}
  {{- if .Values.tls.enabled -}}
    {{- printf "%s" .Values.tls.enabled -}}
  {{- else -}}
    {{- if .Values.global -}}
      {{- if .Values.global.tlsEnabled -}}
        {{- printf "%s" .Values.global.tlsEnabled -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- define "fusion.zkConnectionString" -}}
{{- /*
# Determine the number of zookeeper replicas
# - If there is a global `zkReplicaCount` set, then we use that
# - If there isn't use the local `zkReplicaCount` variable
*/ -}}
{{- $tlsEnabled := include "fusion.tls.enabled" . -}}
{{- $zkReplicas:="" -}}
{{- if .Values.global -}}
{{- if .Values.global.zkReplicaCount -}}
{{- $zkReplicas = .Values.global.zkReplicaCount -}}
{{- else -}}
{{- $zkReplicas = .Values.zkReplicaCount -}}
{{- end -}}
{{- else -}}
{{- $zkReplicas = .Values.zkReplicaCount -}}
{{ end }}
{{- /*
# Determine the zookeeper port
# - If these is a global `zkPort` specified then use that,
# - If there isn't then use the local `zkPort` variable
-*/ -}}
{{- $zkPort := "" -}}
{{- if .Values.global -}}
{{- if .Values.global.zkPort -}}
{{- $zkPort = ( .Values.global.zkPort | default .Values.zkPort ) -}}
{{- else -}}
{{- $zkPort = .Values.zkPort -}}
{{- end -}}
{{- else -}}
{{- $zkPort = .Values.zkPort -}}
{{- end -}}

{{- $zkTLSPort := "" -}}
{{- if .Values.global -}}
{{- if .Values.global.zkTLSPort -}}
{{- $zkTLSPort = ( .Values.global.zkTLSPort | default .Values.zkTLSPort ) -}}
{{- else -}}
{{- $zkTLSPort = .Values.zkTLSPort -}}
{{- end -}}
{{- else -}}
{{- $zkTLSPort = .Values.zkTLSPort -}}
{{- end -}}

{{- /*
# Determine the zookeeper connection string
# - If we have a global `zkConnectionString` defined then we use that
# - Else if we have a local `zkConnectionString` defined then use that
# - Else construct the zkConnection string using the zkReplicas and zkPort
#   variables that we determined before.
*/ -}}
{{- $providedConnectionString := "" -}}
{{- if .Values.zkConnectionString -}}
  {{- $providedConnectionString = .Values.zkConnectionString -}}
  {{ printf "%s" $providedConnectionString }}
{{- else -}}
{{- if .Values.global }}
  {{- if .Values.global.zkConnectionString -}}
    {{- $providedConnectionString = .Values.global.zkConnectionString -}}
    {{ printf "%s" $providedConnectionString }}
  {{- else -}}
    {{- range $i := until ( int ( $zkReplicas )) -}}
      {{- if $tlsEnabled }}
         {{- if ne $i 0 }},{{ end }}{{- printf "%s-zookeeper-%d.%s-%s:%d" $.Release.Name $i $.Release.Name "zookeeper-headless" (int $zkTLSPort) -}}
      {{- else }}
         {{- if ne $i 0 }},{{ end }}{{- printf "%s-zookeeper-%d.%s-%s:%d" $.Release.Name $i $.Release.Name "zookeeper-headless" (int $zkPort) -}}
      {{- end }}
    {{- end -}}
  {{- end -}}
{{- else -}}
  {{- range $i := until ( int ( $zkReplicas )) -}}
    {{- if $tlsEnabled }}
        {{- if ne $i 0 }},{{ end }}{{- printf "%s-zookeeper-%d.%s-%s:%d" $.Release.Name $i $.Release.Name "zookeeper-headless" (int $zkTLSPort) -}}
    {{- else }}
        {{- if ne $i 0 }},{{ end }}{{- printf "%s-zookeeper-%d.%s-%s:%d" $.Release.Name $i $.Release.Name "zookeeper-headless" (int $zkPort) -}}
    {{- end }}
    {{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "fusion.zkSolrConnectionString" -}}
{{- /*
# Determine the number of zookeeper replicas
# - If there is a global `zkReplicaCount` set, then we use that
# - If there isn't use the local `zkReplicaCount` variable
*/ -}}
{{- $tlsEnabled := include "fusion.tls.enabled" . -}}
{{- $zkReplicas:="" -}}
{{- if .Values.global -}}
{{- if .Values.global.zkReplicaCount -}}
{{- $zkReplicas = .Values.global.zkReplicaCount -}}
{{- else -}}
{{- $zkReplicas = .Values.zkReplicaCount -}}
{{- end -}}
{{- else -}}
{{- $zkReplicas = .Values.zkReplicaCount -}}
{{ end }}
{{- /*
# Determine the zookeeper port
# - If these is a global `zkPort` specified then use that,
# - If there isn't then use the local `zkPort` variable
-*/ -}}
{{- $zkPort := "" -}}
{{- if .Values.global -}}
{{- if .Values.global.zkPort -}}
{{- $zkPort = ( .Values.global.zkPort | default .Values.zkPort ) -}}
{{- else -}}
{{- $zkPort = .Values.zkPort -}}
{{- end -}}
{{- else -}}
{{- $zkPort = .Values.zkPort -}}
{{- end -}}

{{- $zkTLSPort := "" -}}
{{- if .Values.global -}}
{{- if .Values.global.zkTLSPort -}}
{{- $zkTLSPort = ( .Values.global.zkTLSPort | default .Values.zkTLSPort ) -}}
{{- else -}}
{{- $zkTLSPort = .Values.zkTLSPort -}}
{{- end -}}
{{- else -}}
{{- $zkTLSPort = .Values.zkTLSPort -}}
{{- end -}}

{{- $zkSolrChrootPath := "" -}}
{{- if .Values.global -}}
{{- if .Values.global.zkSolrChrootPath -}}
{{- $zkSolrChrootPath = ( .Values.global.zkSolrChrootPath | default .Values.zkSolrChrootPath ) -}}
{{- else -}}
{{- $zkSolrChrootPath = .Values.zkSolrChrootPath -}}
{{- end -}}
{{- else -}}
{{- $zkSolrChrootPath = .Values.zkSolrChrootPath -}}
{{- end -}}

{{- $providedConnectionString := "" -}}
{{- if .Values.zkConnectionString -}}
{{- $providedConnectionString = .Values.zkConnectionString -}}
{{- end -}}
{{- if .Values.global }}
{{- if .Values.global.zkConnectionString -}}
{{- $providedConnectionString = .Values.global.zkConnectionString -}}
{{- end -}}
{{- end -}}

{{- $providedSolrConnectionString := "" -}}
{{- if .Values.zkSolrConnectionString -}}
{{- $providedSolrConnectionString = .Values.zkSolrConnectionString -}}
{{- end -}}
{{- if .Values.global }}
{{- if .Values.global.zkSolrConnectionString -}}
{{- $providedSolrConnectionString = .Values.global.zkSolrConnectionString -}}
{{- end -}}
{{- end -}}

{{- /*
# Determine the solr zookeeper connection string
# First tries to look for zkSolrConnectionString, then original zkConnectionString. In both cases defining zkSolrChrootPath is illegal (cannot be appended).
# If both predefined connection strings are missing then build the string with default names and optionally with zkSolrChrootPath.
*/ -}}

{{- if $providedSolrConnectionString -}}
{{- if $zkSolrChrootPath }}{{ fail "You cannot define both: zkSolrConnectionString and zkSolrChrootPath" }}{{ end -}}
{{ $providedSolrConnectionString }}
{{- else if $providedConnectionString -}}
{{- if $zkSolrChrootPath }}{{ fail "You cannot define both: zkConnectionString and zkSolrChrootPath. Define zkSolrConnectionString with appended chroot." }}{{ end -}}
{{ $providedConnectionString }}
{{- else -}}
{{- range $i := until ( int ( $zkReplicas )) -}}
{{- if $tlsEnabled }}
    {{- if ne $i 0 }},{{ end }}{{- printf "%s-zookeeper-%d.%s-%s:%d" $.Release.Name $i $.Release.Name "zookeeper-headless" (int $zkTLSPort) -}}{{ if $zkSolrChrootPath }}{{ $zkSolrChrootPath }}{{ end -}}
{{- else }}
    {{- if ne $i 0 }},{{ end }}{{- printf "%s-zookeeper-%d.%s-%s:%d" $.Release.Name $i $.Release.Name "zookeeper-headless" (int $zkPort) -}}{{ if $zkSolrChrootPath }}{{ $zkSolrChrootPath }}{{ end -}}
{{- end }}
{{- end -}}
{{- end -}}

{{- end -}}

## Define an initContainer for setting up the tls certificates
{{- define "fusion.tls.init-container-v2" -}}
{{- if not .tls.generateCert -}}
{{- if (eq .tls.certSecret.name "") }}
{{- fail "Either .tls.generateCert or .tls.certSecret.name must be specified" }}
{{- end -}}
{{- end -}}
{{- $tlsDuration:="" -}}
{{- if .global -}}
{{- if .global.tlsDuration -}}
{{- $tlsDuration = .global.tlsDuration -}}
{{- else -}}
{{- $tlsDuration = .tls.duration -}}
{{- end -}}
{{- else -}}
{{- $tlsDuration = .tls.duration -}}
{{ end }}

{{- $tlsRenewBefore:="" -}}
{{- if .global -}}
{{- if .global.tlsRenewBefore -}}
{{- $tlsRenewBefore = .global.tlsRenewBefore -}}
{{- else -}}
{{- $tlsRenewBefore = .tls.renewBefore -}}
{{- end -}}
{{- else -}}
{{- $tlsRenewBefore = .tls.renewBefore -}}
{{ end }}

{{- $tlsIssuerRef:="" -}}
{{- if .global -}}
{{- if .global.tlsIssuerRef -}}
{{- $tlsIssuerRef = .global.tlsIssuerRef -}}
{{- else -}}
{{- $tlsIssuerRef = .tls.issuerRef.name -}}
{{- end -}}
{{- else -}}
{{- $tlsIssuerRef = .tls.issuerRef.name -}}
{{ end }}

{{- $tlsIssuerKind:="" -}}
{{- if .global -}}
{{- if .global.tlsIssuerKind -}}
{{- $tlsIssuerKind = .global.tlsIssuerKind -}}
{{- else -}}
{{- $tlsIssuerKind = .tls.issuerRef.kind -}}
{{- end -}}
{{- else -}}
{{- $tlsIssuerKind = .tls.issuerRef.kind -}}
{{ end }}

{{- $additionalServices := list -}}
{{- if .additionalServices -}}
{{- $additionalServices = .additionalServices -}}
{{- end -}}

- name: "setup-keystore-and-properties"
  image: "{{ .keytoolUtils.image.repository }}/{{ .keytoolUtils.image.name }}:{{ .keytoolUtils.image.tag }}"
  imagePullPolicy: "{{ .keytoolUtils.image.imagePullPolicy }}"
  securityContext:
    readOnlyRootFilesystem: true
    runAsNonRoot: true
    allowPrivilegeEscalation: false
    privileged: false
{{- if .securityContext.runAsUser }}
{{- end }}
  command:
    - "/bin/bash"
    - "-c"
    - |
      set -e
      WORKSPACE="/tmp/keystore"
      export TMPDIR="${WORKSPACE}"
      CERT_PATH="${WORKSPACE}"
      CA_PATH="${WORKSPACE}"
      KEY_NAME="tls.key"
      CERT_NAME="tls.crt"
      CA_FILE_NAME="ca.crt"

{{- if .tls.generateCert }}
      # Remove the certificate if it already exists
      if kubectl --namespace "{{ .Release.Namespace }}" get certificate "${POD_HOSTNAME}-tls"; then
        kubectl --namespace "{{ .Release.Namespace }}" delete certificate "${POD_HOSTNAME}-tls"

        while [[ $(kubectl --namespace "{{ .Release.Namespace }}" get certificate "${POD_HOSTNAME}-tls") ]]; do
          echo "Waiting for certificate to disappear before recreating"
          sleep 2
        done

      fi

      # Create certificate
      cat <<EOF | kubectl apply --namespace "{{ .Release.Namespace }}" -f -
      apiVersion: cert-manager.io/v1
      kind: Certificate
      metadata:
        name: "${POD_HOSTNAME}-tls"
        ownerReferences:
          - apiVersion: v1
            blockOwnerDeletion: false
            controller: false
            kind: Pod
            name: "${POD_HOSTNAME}"
            uid: "${POD_UID}"
      spec:
        # Secret names are always required.
        secretName: "${POD_HOSTNAME}-tls"
        duration: {{ $tlsDuration }}
        renewBefore: {{ $tlsRenewBefore }}
        subject:
          organizations:
            - lucidworks
        # At least one of a DNS Name, USI SAN, or IP address is required.
        dnsNames:
          - "{{ .tlsServiceName }}"
          - "{{ .tlsServiceName }}.{{ .Release.Namespace }}.{{ .tls.clusterDomain }}"
          - "${POD_HOSTNAME}.{{ .tlsServiceName }}"
          - "${POD_HOSTNAME}.{{ .tlsServiceName }}.{{ .Release.Namespace }}.{{ .tls.clusterDomain }}"
{{- range $i, $service := $additionalServices }}
          - "{{ $service }}"
{{- end }}
        ipAddresses:
          - "${POD_IP}"
        issuerRef:
          name: {{ $tlsIssuerRef }}
          # We can reference ClusterIssuers by changing the kind here.
          # The default value is Issuer (i.e. a locally namespaced Issuer)
          kind: {{ $tlsIssuerKind }}
          # This is optional since cert-manager will default to this value however
          # if you are using an external issuer, change this to that issuer group.
          group: cert-manager.io
      EOF

      # Wait for certificate to become ready
      while ! [[ $(kubectl --namespace "{{ .Release.Namespace }}" get certificate "${POD_HOSTNAME}-tls" -o "jsonpath={.status.conditions[0].status}") == "True" ]]; do
        echo "Waiting for certificate to become ready"
        sleep 5
      done

      while ! [[ $(kubectl --namespace "{{ .Release.Namespace }}" get secret "${POD_HOSTNAME}-tls") ]]; do
        echo "Waiting for secret to appear"
        sleep 5
      done

      kubectl --namespace "{{ .Release.Namespace }}" get secret "${POD_HOSTNAME}-tls" -o jsonpath={.data.ca\\.crt} | base64 -d > "${WORKSPACE}/${CA_FILE_NAME}"
      kubectl --namespace "{{ .Release.Namespace }}" get secret "${POD_HOSTNAME}-tls" -o jsonpath={.data.tls\\.crt} | base64 -d > "${WORKSPACE}/${CERT_NAME}"
      kubectl --namespace "{{ .Release.Namespace }}" get secret "${POD_HOSTNAME}-tls" -o jsonpath={.data.tls\\.key} | base64 -d > "${WORKSPACE}/${KEY_NAME}"
{{- else -}}
{{- if not (eq .tls.certSecret.name "") }}
      CERT_PATH="/tmp/tls_certificate"
      KEY_NAME="{{ .tls.certSecret.keyPath }}"
      CERT_NAME="{{ .tls.certSecret.crtPath }}"
{{- end }}
{{- if not (eq .tls.caSecret.name "") }}
      CA_PATH="/tmp/tls_ca"
      CA_FILE_NAME="{{ .tls.caSecret.caPath }}"
{{- end }}
{{- end }}
{{- if .tls.generateJKS }}
      PKCS12_OUTPUT="${WORKSPACE}/keystore.pkcs12"
      DEST_KEYSTORE="${WORKSPACE}/keystore.jks"
      DEST_TRUSTSTORE="${WORKSPACE}/truststore.jks"
      PASSWORD={{ .tls.keystorePassword }}

      cd "${WORKSPACE}"

      if [ -f "${DEST_KEYSTORE}" ]; then
        rm "${DEST_KEYSTORE}"
      fi

      if [ -f "${DEST_TRUSTSTORE}" ]; then
        rm "${DEST_TRUSTSTORE}"
      fi

      openssl "pkcs12" -export -inkey "${CERT_PATH}/${KEY_NAME}" \
        -in "${CERT_PATH}/${CERT_NAME}" -out "${PKCS12_OUTPUT}" \
        -password "pass:${PASSWORD}"

      keytool -importkeystore -noprompt -srckeystore "${PKCS12_OUTPUT}" \
        -srcstoretype "pkcs12" -destkeystore "${DEST_KEYSTORE}" \
        -storepass "${PASSWORD}" -srcstorepass "${PASSWORD}"

      keytool -importkeystore -noprompt -srckeystore "/usr/local/openjdk-11/lib/security/cacerts" \
        -destkeystore "${DEST_TRUSTSTORE}" -storepass "${PASSWORD}"

      csplit -z -f crt- /var/run/secrets/kubernetes.io/serviceaccount/ca.crt '/-----BEGIN CERTIFICATE-----/' '{*}'
      for file in crt-*; do
        keytool -import -noprompt -keystore "${DEST_TRUSTSTORE}" -file "${file}" -storepass "${PASSWORD}" -alias kubernetes-$file;
      done
      rm crt-*

      if [ -f "${CA_PATH}/${CA_FILE_NAME}" ]; then
        csplit -z -f crt- "${CA_PATH}/${CA_FILE_NAME}" '/-----BEGIN CERTIFICATE-----/' '{*}'
        for file in crt-*; do
          keytool -importcert -noprompt -deststoretype "pkcs12" -keystore "${DEST_TRUSTSTORE}" -file "${file}" -storepass "${PASSWORD}" -alias ca-$file;
        done
      fi
      rm crt-*
{{- if .tls.generatePasswdFile }}
      cat > "${DEST_TRUSTSTORE}.passwd" <<< "${PASSWORD}"
      cat > "${DEST_KEYSTORE}.passwd" <<< "${PASSWORD}"
{{- end }}
{{- end }}
  volumeMounts:
    - name: "keystore-volume"
      mountPath: "/tmp/keystore"
    - name: "workspace"
      mountPath: "/workspace"
{{- if not (eq .tls.certSecret.name "") }}
    - name: "tls-secret"
      mountPath: "/tmp/tls_certificate"
      readOnly: true
{{- end }}
{{- if not (eq .tls.caSecret.name "") }}
    - name: "tls-ca"
      mountPath: "/tmp/tls_ca"
      readOnly: true
{{- end }}
  env:
    - name: "POD_HOSTNAME"
      valueFrom:
        fieldRef:
          fieldPath: metadata.name
    - name: "POD_UID"
      valueFrom:
        fieldRef:
          fieldPath: metadata.uid
    - name: "POD_IP"
      valueFrom:
        fieldRef:
          fieldPath: status.podIP
{{- end -}}

{{- define "fusion.tls.volumes" -}}
- name: keystore-volume
  emptyDir: {}
- name: workspace
  emptyDir: {}
{{- if not (eq .tls.certSecret.name  "") }}
- name: "tls-secret"
  secret:
    secretName: {{ .tls.certSecret.name }}
{{- end }}
{{- if not (eq .tls.caSecret.name  "") }}
- name: "tls-ca"
  secret:
    secretName: {{ .tls.caSecret.name }}
{{- end }}
{{- end }}

{{- define "fusion.initContainers.checkZk-v2" -}}
{{- $tlsEnabled := include "fusion.tls.enabled" . -}}
- name: check-zk
  image: {{ .Values.image.repository }}/check-fusion-dependency:v1.6.0
  imagePullPolicy: IfNotPresent
  securityContext:
    readOnlyRootFilesystem: true
    runAsNonRoot: true
    allowPrivilegeEscalation: false
    privileged: false
  args:
    - zookeeper
  resources:
    requests:
      cpu: 200m
      memory: 32Mi
    limits:
      cpu: 200m
      memory: 32Mi
  env:
    - name: ZOOKEEPER_CONNECTION_STRING
      value: {{ include "fusion.zkConnectionString" . }}
    - name: CHECK_INTERVAL
      value: {{ .Values.zkInitCheckInterval | default "5s" }}
    - name: CHECK_TIMEOUT
      value: {{ .Values.zkInitCheckTimeout | default "2s" }}
    - name: TIMEOUT
      value: {{ .Values.zkInitTimeout | default "2m" }}
{{- if $tlsEnabled }}
    - name: ADDITIONAL_CA_CERTIFICATE
      value: "/tls/ca.crt"
    - name: "TLS_ENABLED"
      value: "true"
  volumeMounts:
    - name: keystore-volume
      mountPath: /tls
{{- end }}
{{- end -}}


{{- define "fusion.initContainers.checkLogstash-v2" -}}
- name: check-logstash
  image: {{ .Values.image.repository }}/check-fusion-dependency:v1.6.0
  imagePullPolicy: IfNotPresent
  securityContext:
    readOnlyRootFilesystem: true
    runAsNonRoot: true
    allowPrivilegeEscalation: false
    privileged: false
  resources:
    requests:
      cpu: 200m
      memory: 32Mi
    limits:
      cpu: 200m
      memory: 32Mi
  args:
    - logstash
  env:
    - name: LOGSTASH_ENDPOINT
      value: {{ include "fusion.logstashWebHost" . }}
    - name: LOGSTASH_PORT
      value: {{ include "fusion.logstashWebPort" . | quote }}
    - name: CHECK_INTERVAL
      value: {{ .Values.logstashInitCheckInterval | default "5s" }}
    - name: CHECK_TIMEOUT
      value: {{ .Values.logstashInitCheckTimeout | default "2s" }}
    - name: TIMEOUT
      value: {{ .Values.logstashInitTimeout | default "2m" }}
{{- end -}}


{{- define "fusion.initContainers.checkAdmin-v2" -}}
{{- $tlsEnabled := include "fusion.tls.enabled" . -}}
- name: check-admin
  image: {{ .Values.image.repository }}/check-fusion-dependency:v1.6.0
  imagePullPolicy: IfNotPresent
  securityContext:
    readOnlyRootFilesystem: true
    runAsNonRoot: true
    allowPrivilegeEscalation: false
    privileged: false
  resources:
    requests:
      cpu: 200m
      memory: 32Mi
    limits:
      cpu: 200m
      memory: 32Mi
  args:
    - admin
  env:
    - name: ADMIN_ENDPOINT
{{- if $tlsEnabled }}
      value: {{ .Values.adminEndpoint | default ( printf "%s://admin" "https") }}
{{- else }}
      value: {{ .Values.adminEndpoint | default ( printf "%s://admin" "http" ) }}
{{- end }}
    - name: ADMIN_PORT
      value: {{ .Values.adminPort | default 8765 | quote }}
    - name: CHECK_INTERVAL
      value: {{ .Values.adminInitCheckInterval | default "5s" }}
    - name: CHECK_TIMEOUT
      value: {{ .Values.adminInitCheckTimeout | default "2s" }}
    - name: TIMEOUT
      value: {{ .Values.adminInitTimeout | default "2m" }}
{{- if $tlsEnabled }}
    - name: ADDITIONAL_CA_CERTIFICATE
      value: "/tls/ca.crt"
  volumeMounts:
    - name: keystore-volume
      mountPath: /tls
{{- end }}

{{- end -}}


{{- define "fusion.initContainers.checkIndexing" -}}
{{- $tlsEnabled := include "fusion.tls.enabled" . -}}
- name: check-indexing
  image: {{ .Values.image.repository }}/check-fusion-dependency:v1.6.0
  imagePullPolicy: IfNotPresent
  securityContext:
    readOnlyRootFilesystem: true
    runAsNonRoot: true
    allowPrivilegeEscalation: false
    privileged: false
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
{{- if $tlsEnabled }}
      value: {{ .Values.adminEndpoint | default ( printf "%s://indexing" "https") }}
{{- else }}
      value: {{ .Values.adminEndpoint | default ( printf "%s://indexing" "http" ) }}
{{- end }}
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


{{- define "fusion.initContainers.checkApiGateway" -}}
{{- $tlsEnabled := include "fusion.tls.enabled" . -}}
- name: check-api-gateway
  image: {{ .Values.image.repository }}/check-fusion-dependency:v1.6.0
  imagePullPolicy: IfNotPresent
  securityContext:
    readOnlyRootFilesystem: true
    runAsNonRoot: true
    allowPrivilegeEscalation: false
    privileged: false
  resources:
    requests:
      cpu: 200m
      memory: 32Mi
    limits:
      cpu: 200m
      memory: 32Mi
  args:
    - api-gateway
  env:
    - name: API_GATEWAY_ENDPOINT
{{- if $tlsEnabled }}
      value: {{ .Values.adminEndpoint | default ( printf "%s://proxy" "https") }}
{{- else }}
      value: {{ .Values.adminEndpoint | default ( printf "%s://proxy" "http" ) }}
{{- end }}
    - name: API_GATEWAY_PORT
      value: {{ .Values.proxyPort | default 6764 | quote }}
    - name: CHECK_INTERVAL
      value: {{ .Values.proxyInitCheckInterval | default "5s" }}
    - name: CHECK_TIMEOUT
      value: {{ .Values.proxyInitCheckTimeout | default "2s" }}
    - name: TIMEOUT
      value: {{ .Values.proxyInitTimeout | default "3m" }}
{{- if $tlsEnabled }}
    - name: ADDITIONAL_CA_CERTIFICATE
      value: "/tls/ca.crt"
  volumeMounts:
    - name: keystore-volume
      mountPath: /tls
{{- end }}
{{- end -}}

{{/*
Define the admin url for pulsar broker
*/}}
{{- define "fusion.pulsarAdminUrl" -}}
{{- $tlsEnabled := ( eq (include "fusion.tls.enabled" $ ) "true" ) -}}
{{- if .Values.global -}}
{{- if .Values.global.pulsarAdminUrl -}}
{{- printf "%s" .Values.global.pulsarAdminUrl -}}
{{- end -}}
{{- end -}}
{{- if .Values.pulsarAdminUrl -}}
{{- printf "%s" .Values.pulsarAdminUrl -}}
{{- else -}}
{{- if $tlsEnabled }}
{{- printf "%s://%s-pulsar-broker:%s" "https" .Release.Name "8443" -}}
{{- else }}
{{- printf "%s://%s-pulsar-broker:%s" "http" .Release.Name "8080" -}}
{{- end }}
{{- end -}}
{{- end -}}

{{- define "fusion.initContainers.checkPulsar-v2" -}}
{{- $tlsEnabled := include "fusion.tls.enabled" $ -}}
- name: check-pulsar
  image: {{ .Values.image.repository }}/check-fusion-dependency:v1.6.0
  imagePullPolicy: IfNotPresent
  securityContext:
    readOnlyRootFilesystem: true
    runAsNonRoot: true
    allowPrivilegeEscalation: false
    privileged: false
  resources:
    requests:
      cpu: 200m
      memory: 32Mi
    limits:
      cpu: 200m
      memory: 32Mi
  args:
    - pulsar
  env:
    - name: PULSAR_ENDPOINT
      value: {{ include "fusion.pulsarAdminUrl" . | quote }}
    - name: CHECK_INTERVAL
      value: {{ .Values.pulsarInitCheckInterval | default "5s" }}
    - name: CHECK_TIMEOUT
      value: {{ .Values.pulsarInitCheckTimeout | default "2s" }}
    - name: TIMEOUT
      value: {{ .Values.pulsarInitTimeout | default "2m" }}
{{- if $tlsEnabled }}
    - name: ADDITIONAL_CA_CERTIFICATE
      value: "/tls/ca.crt"
  volumeMounts:
    - name: keystore-volume
      mountPath: /tls
{{- end }}
{{- end -}}

{{- define "fusion.loggingDisablePulsar" -}}
{{- $pulsarDisabled := false -}}
{{- if .Values.global -}}
{{- if .Values.global.logging -}}
{{- if .Values.global.logging.disablePulsar -}}
{{ $pulsarDisabled = true -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- $pulsarDisabled -}}
{{- end -}}

{{- define "fusion.loggingJSONOutput" -}}
{{- $jsonOutput := false -}}
{{- if .Values.global -}}
{{- if .Values.global.logging -}}
{{- if .Values.global.logging.jsonOutput -}}
{{ $jsonOutput = true -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- $jsonOutput -}}
{{- end -}}

{{- define "fusion.logstashHost" -}}
{{- $logstashHost := "" -}}
{{- if .Values.global -}}
{{- if .Values.global.logging -}}
{{- if .Values.global.logging.logstashHost -}}
{{ $logstashHost = .Values.global.logging.logstashHost -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- $logstashHost -}}
{{- end -}}


{{/*
Define the kafka endpoint
*/}}
{{- /*
# Determine the kafka connection string
# - If we have a global `kafkaSvcUrl` defined then we use that
# - Else if we have a local `kafkaSvcUrl` defined then use that
*/ -}}
{{- define "fusion.kafkaSvcUrl" -}}

{{- /*
# Determine the kafka port
# - If these is a global `kafkaPort` specified then use that,
# - If there isn't then use the local `kafkaPort` variable
-*/ -}}
{{- $kafkaPort := "" -}}
  {{- if .Values.global -}}
    {{- if .Values.global.kafkaPort -}}
      {{- $kafkaPort =  ( int .Values.global.kafkaPort ) -}}
    {{- else -}}
      {{- $kafkaPort = ( int .Values.kafkaPort ) -}}
    {{- end -}}
  {{- else -}}
    {{- $kafkaPort = ( int .Values.kafka.servicePort ) -}}
  {{- end -}}


{{- $tlsEnabled := include "fusion.tls.enabled" $ -}}
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

    {{- if .Values.global }}
        {{- if .Values.global.kafkaSvcUrl -}}
            {{- printf "%s" .Values.global.kafkaSvcUrl -}}
        {{- else if .Values.kafkaSvcUrl -}}
            {{- printf "%s" .Values.kafkaSvcUrl -}}
        {{- else -}}
            {{- range $i := until ( int ( $kafkaReplicas )) -}}
            {{- if ne $i 0 }},{{ end }}{{- printf "%s-kafka-%d.%s-%s" $.Release.Name $i $.Release.Name "kafka-headless:9092" -}}
            {{- end -}}
        {{- end -}}
    {{- else if .Values.kafkaSvcUrl -}}
        {{- printf "%s" .Values.kafkaSvcUrl -}}
    {{- else -}}
        {{- range $i := until ( int ( $kafkaReplicas )) -}}
        {{- if ne $i 0 }},{{ end }}{{- printf "%s-kafka-%d.%s-%s.%s.%s" $.Release.Name $i $.Release.Name "kafka-headless" $.Release.Name "svc.cluster.local:9092" -}}
        {{- end -}}
    {{- end -}}
{{- end -}}


{{- define "fusion.initContainers.checkKafka" -}}
{{- $tlsEnabled := include "fusion.tls.enabled" $ -}}
- name: check-kafka
  image: {{ .Values.image.repository }}/check-fusion-dependency:v1.4.0
  imagePullPolicy: IfNotPresent
  securityContext:
    readOnlyRootFilesystem: true
    runAsNonRoot: true
    allowPrivilegeEscalation: false
    privileged: false
  resources:
    requests:
      cpu: 200m
      memory: 32Mi
    limits:
      cpu: 200m
      memory: 32Mi
  args:
    - kafka
  env:
    - name: KAFKA_ENDPOINT
      value: {{ include "fusion.kafkaSvcUrl" . }}
    - name: CHECK_INTERVAL
      value: {{ .Values.kafkaInitCheckInterval | default "5s" }}
    - name: CHECK_TIMEOUT
      value: {{ .Values.kafkaInitCheckTimeout | default "2s" }}
    - name: TIMEOUT
      value: {{ .Values.kafkaInitTimeout | default "2m" }}
{{- if $tlsEnabled }}
    - name: ADDITIONAL_CA_CERTIFICATE
      value: "/tls/ca.crt"
  volumeMounts:
    - name: keystore-volume
      mountPath: /tls
{{- end }}
{{- end -}}
