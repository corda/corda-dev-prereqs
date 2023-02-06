{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "corda-dev.fullname" -}}
{{- $name := .Chart.Name }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Name for PostgreSQL related resources.
*/}}
{{- define "corda-dev.postgresName" -}}
{{ printf "%s-postgres" ( .Release.Name | trunc 54 | trimSuffix "-" ) }}
{{- end }}

{{/*
Name for Kafka related resources.
*/}}
{{- define "corda-dev.kafkaName" -}}
{{ printf "%s-kafka" ( .Release.Name | trunc 54 | trimSuffix "-" ) }}
{{- end }}

{{/*
PostgreSQL probe command.
*/}}
{{- define "corda-dev.postgresProbe" -}}
exec:
  command:
    - /bin/sh
    - -c
    - exec pg_isready -U postgres -d "sslcert=/certs/server.crt sslkey=/certs/server.key" -h 127.0.0.1 -p 5432
{{- end }}

{{/*
Kafka probe command.
*/}}
{{- define "corda-dev.kafkaProbe" -}}
tcpSocket:
  port: "ssl"
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "corda-dev.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "corda-dev.labels" -}}
helm.sh/chart: {{ include "corda-dev.chart" . }}
{{ include "corda-dev.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service | quote }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "corda-dev.selectorLabels" -}}
app.kubernetes.io/name: "corda-dev"
app.kubernetes.io/instance: {{ .Release.Name | quote }}
{{- end }}
