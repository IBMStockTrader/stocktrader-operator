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


{{/*
Database helper templates - support both internal subcharts and external databases
*/}}

{{/*
Get database host - uses subchart if internal, otherwise external config
*/}}
{{- define "stocktrader.database.host" -}}
{{- if eq .Values.database.type "internal" -}}
{{- if eq .Values.database.kind "postgres" -}}
{{- printf "%s-postgresql" .Release.Name -}}
{{- else if eq .Values.database.kind "MongoDB" -}}
{{- printf "%s-mongodb" .Release.Name -}}
{{- else -}}
{{- printf "%s-postgresql" .Release.Name -}}
{{- end -}}
{{- else -}}
{{- .Values.database.external.host -}}
{{- end -}}
{{- end -}}

{{/*
Get database port - uses subchart defaults if internal, otherwise external config
*/}}
{{- define "stocktrader.database.port" -}}
{{- if eq .Values.database.type "internal" -}}
{{- if eq .Values.database.kind "postgres" -}}
{{- .Values.postgresql.primary.service.ports.postgresql | default 5432 -}}
{{- else if eq .Values.database.kind "MongoDB" -}}
{{- .Values.mongodb.service.ports.mongodb | default 27017 -}}
{{- else -}}
{{- .Values.postgresql.primary.service.ports.postgresql | default 5432 -}}
{{- end -}}
{{- else -}}
{{- .Values.database.external.port -}}
{{- end -}}
{{- end -}}

{{/*
Get database name - uses subchart config if internal, otherwise external config
*/}}
{{- define "stocktrader.database.name" -}}
{{- if eq .Values.database.type "internal" -}}
{{- if eq .Values.database.kind "postgres" -}}
{{- .Values.postgresql.auth.database | default "trader" -}}
{{- else if eq .Values.database.kind "MongoDB" -}}
{{- .Values.mongodb.auth.database | default "trader" -}}
{{- else -}}
{{- .Values.postgresql.auth.database | default "trader" -}}
{{- end -}}
{{- else -}}
{{- .Values.database.external.db -}}
{{- end -}}
{{- end -}}

{{/*
Get database username - uses subchart config if internal, otherwise external config
*/}}
{{- define "stocktrader.database.username" -}}
{{- if eq .Values.database.type "internal" -}}
{{- if eq .Values.database.kind "postgres" -}}
{{- .Values.postgresql.auth.username | default "stocktrader" -}}
{{- else if eq .Values.database.kind "MongoDB" -}}
{{- .Values.mongodb.auth.username | default "stocktrader" -}}
{{- else -}}
{{- .Values.postgresql.auth.username | default "stocktrader" -}}
{{- end -}}
{{- else -}}
{{- .Values.database.external.id -}}
{{- end -}}
{{- end -}}

{{/*
Get database password - uses subchart config if internal, otherwise external config
*/}}
{{- define "stocktrader.database.password" -}}
{{- if eq .Values.database.type "internal" -}}
{{- if eq .Values.database.kind "postgres" -}}
{{- .Values.postgresql.auth.password | default "changeme" -}}
{{- else if eq .Values.database.kind "MongoDB" -}}
{{- .Values.mongodb.auth.password | default "changeme" -}}
{{- else -}}
{{- .Values.postgresql.auth.password | default "changeme" -}}
{{- end -}}
{{- else -}}
{{- .Values.database.external.password -}}
{{- end -}}
{{- end -}}

{{/*
Get database SSL setting - uses subchart defaults if internal, otherwise external config
*/}}
{{- define "stocktrader.database.ssl" -}}
{{- if eq .Values.database.type "internal" -}}
{{- "false" -}}
{{- else -}}
{{- .Values.database.external.ssl -}}
{{- end -}}
{{- end -}}


