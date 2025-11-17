{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "trader.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "trader.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Determine the OpenTelemetry collector image based on environment.
If environment is 'production', use the image repository defined in values.yaml.
Otherwise, default to the community image.
*/}}
{{- define "otel.collector.image" -}}
{{- if and (eq .Values.global.environment "production") .Values.global.opentelemetry.collector.image -}}
{{- printf "%s:%s" .Values.global.opentelemetry.collector.image.repository .Values.global.opentelemetry.collector.image.tag -}}
{{- else -}}
otel/opentelemetry-collector-contrib:latest
{{- end -}}
{{- end -}}

{{/*
Determine the OpenTelemetry agent image based on environment.
If environment is 'production', use the image repository defined in values.yaml.
Otherwise, default to the community image.
*/}}
{{- define "otel.agent.image" -}}
{{- if eq .Values.global.environment "production" -}}
{{- printf "%s:%s" .Values.global.opentelemetry.agent.image.repository .Values.global.opentelemetry.agent.image.tag -}}
{{- else -}}
otel/opentelemetry-collector:latest
{{- end -}}
{{- end -}}


