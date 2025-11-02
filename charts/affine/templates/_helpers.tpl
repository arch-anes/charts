{{- define "affine.fullname" -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "affine.secretOrValue" -}}
{{- if .config.secret.name -}}
valueFrom:
  secretKeyRef:
    name: {{ .config.secret.name }}
    key: {{ .config.secret.key }}
{{- else -}}
value: {{ .config.value | quote }}
{{- end -}}
{{- end }}

{{- define "affine.dbUsername" -}}
{{- include "affine.secretOrValue" (dict "config" .Values.externalDatabase.username "context" .) }}
{{- end }}

{{- define "affine.dbPassword" -}}
{{- include "affine.secretOrValue" (dict "config" .Values.externalDatabase.password "context" .) }}
{{- end }}

{{- define "affine.redisPassword" -}}
{{- include "affine.secretOrValue" (dict "config" .Values.externalRedis.password "context" .) }}
{{- end }}

{{- define "affine.smtpHost" -}}
{{- include "affine.secretOrValue" (dict "config" .Values.smtp.host "context" .) }}
{{- end }}

{{- define "affine.smtpPort" -}}
{{- include "affine.secretOrValue" (dict "config" .Values.smtp.port "context" .) }}
{{- end }}

{{- define "affine.smtpUser" -}}
{{- include "affine.secretOrValue" (dict "config" .Values.smtp.username "context" .) }}
{{- end }}

{{- define "affine.smtpPassword" -}}
{{- include "affine.secretOrValue" (dict "config" .Values.smtp.password "context" .) }}
{{- end }}

{{- define "affine.smtpSender" -}}
{{- include "affine.secretOrValue" (dict "config" .Values.smtp.sender "context" .) }}
{{- end }}

{{- define "affine.databaseUrl" -}}
{{- if .Values.postgresql.enabled -}}
postgres://{{ .Values.postgresql.auth.username }}:{{ .Values.postgresql.auth.password }}@{{ .Release.Name }}-postgresql:5432/{{ .Values.postgresql.auth.database }}
{{- else -}}
postgres://$(DB_USERNAME):$(DB_PASSWORD)@{{ .Values.externalDatabase.host }}:{{ .Values.externalDatabase.port }}/{{ .Values.externalDatabase.database }}
{{- end -}}
{{- end }}

{{- define "affine.baseUrl" -}}
https://{{ .Values.baseFqdn }}
{{- end }}

{{- define "affine.commonEnv" -}}
- name: DEPLOYMENT_TYPE
  value: "selfhosted"
- name: NODE_OPTIONS
  value: "--max-old-space-size=2048"
- name: NO_COLOR
  value: "1"
{{- if not .Values.postgresql.enabled }}
- name: DB_USERNAME
  {{- include "affine.dbUsername" . | nindent 2 }}
- name: DB_PASSWORD
  {{- include "affine.dbPassword" . | nindent 2 }}
{{- end }}
- name: DATABASE_URL
  value: {{ include "affine.databaseUrl" . | quote }}
- name: REDIS_SERVER_HOST
  value: "{{ if .Values.redis.enabled }}{{ .Release.Name }}-redis-master{{ else }}{{ .Values.externalRedis.host }}{{ end }}"
- name: REDIS_SERVER_PORT
  value: "{{ if .Values.redis.enabled }}6379{{ else }}{{ .Values.externalRedis.port }}{{ end }}"
- name: REDIS_SERVER_USER
  value: {{ .Values.externalRedis.username | quote }}
{{- if and (not .Values.redis.enabled) (or .Values.externalRedis.password.value .Values.externalRedis.password.secret.name) }}
- name: REDIS_SERVER_PASSWORD
  {{- include "affine.redisPassword" . | nindent 2 }}
{{- end }}
- name: REDIS_SERVER_DATABASE
  value: {{ .Values.externalRedis.database | quote }}
- name: AFFINE_INDEXER_ENABLED
  value: "false"
- name: AFFINE_SERVER_PORT
  value: "3000"
- name: AFFINE_SERVER_EXTERNAL_URL
  value: {{ include "affine.baseUrl" . | quote }}
- name: UPLOAD_LOCATION
  value: "/root/.affine/storage"
- name: CONFIG_LOCATION
  value: "/root/.affine/config"
{{- if or .Values.smtp.host.value .Values.smtp.host.secret.name }}
- name: MAILER_HOST
  {{- include "affine.smtpHost" . | nindent 2 }}
- name: MAILER_PORT
  {{- include "affine.smtpPort" . | nindent 2 }}
- name: MAILER_USER
  {{- include "affine.smtpUser" . | nindent 2 }}
- name: MAILER_PASSWORD
  {{- include "affine.smtpPassword" . | nindent 2 }}
- name: MAILER_SENDER
  {{- include "affine.smtpSender" . | nindent 2 }}
- name: MAILER_SECURE
  value: {{ .Values.smtp.secure | quote }}
{{- end }}
{{- end }}
