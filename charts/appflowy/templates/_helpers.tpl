{{- define "appflowy.fullname" -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Generic helper to render value or valueFrom for secrets
Usage: include "appflowy.secretOrValue" (dict "config" .Values.path.to.config "context" $)
*/}}
{{- define "appflowy.secretOrValue" -}}
{{- if .config.secret.name -}}
valueFrom:
  secretKeyRef:
    name: {{ .config.secret.name }}
    key: {{ .config.secret.key }}
{{- else -}}
value: {{ .config.value | quote }}
{{- end -}}
{{- end }}

{{- define "appflowy.jwtSecret" -}}
{{- include "appflowy.secretOrValue" (dict "config" .Values.gotrue.jwtSecret "context" .) }}
{{- end }}

{{- define "appflowy.gotrueAdminEmail" -}}
{{- include "appflowy.secretOrValue" (dict "config" .Values.gotrue.adminEmail "context" .) }}
{{- end }}

{{- define "appflowy.gotrueAdminPassword" -}}
{{- include "appflowy.secretOrValue" (dict "config" .Values.gotrue.adminPassword "context" .) }}
{{- end }}

{{- define "appflowy.s3AccessKey" -}}
{{- include "appflowy.secretOrValue" (dict "config" .Values.appflowy.s3.accessKey "context" .) }}
{{- end }}

{{- define "appflowy.s3SecretKey" -}}
{{- include "appflowy.secretOrValue" (dict "config" .Values.appflowy.s3.secretKey "context" .) }}
{{- end }}

{{- define "appflowy.openaiApiKey" -}}
{{- include "appflowy.secretOrValue" (dict "config" .Values.ai.openaiApiKey "context" .) }}
{{- end }}

{{- define "appflowy.smtpHost" -}}
{{- include "appflowy.secretOrValue" (dict "config" .Values.smtp.host "context" .) }}
{{- end }}

{{- define "appflowy.smtpPort" -}}
{{- include "appflowy.secretOrValue" (dict "config" .Values.smtp.port "context" .) }}
{{- end }}

{{- define "appflowy.smtpUsername" -}}
{{- include "appflowy.secretOrValue" (dict "config" .Values.smtp.username "context" .) }}
{{- end }}

{{- define "appflowy.smtpPassword" -}}
{{- include "appflowy.secretOrValue" (dict "config" .Values.smtp.password "context" .) }}
{{- end }}

{{- define "appflowy.dbUsername" -}}
{{- include "appflowy.secretOrValue" (dict "config" .Values.appflowy.externalDatabase.username "context" .) }}
{{- end }}

{{- define "appflowy.dbPassword" -}}
{{- include "appflowy.secretOrValue" (dict "config" .Values.appflowy.externalDatabase.password "context" .) }}
{{- end }}

{{- define "appflowy.redisPassword" -}}
{{- include "appflowy.secretOrValue" (dict "config" .Values.appflowy.externalRedis.password "context" .) }}
{{- end }}

{{- define "appflowy.databaseUrl" -}}
{{- if .Values.postgresql.enabled -}}
postgres://{{ .Values.postgresql.auth.username }}:{{ .Values.postgresql.auth.password }}@{{ .Release.Name }}-postgresql:5432/{{ .Values.postgresql.auth.database }}
{{- else -}}
postgres://$(DB_USERNAME):$(DB_PASSWORD)@{{ .Values.appflowy.externalDatabase.host }}:{{ .Values.appflowy.externalDatabase.port }}/{{ .Values.appflowy.externalDatabase.database }}
{{- end -}}
{{- end }}

{{- define "appflowy.redisUrl" -}}
{{- if .Values.redis.enabled -}}
redis://{{ .Release.Name }}-redis-master:6379
{{- else if or .Values.appflowy.externalRedis.password.value .Values.appflowy.externalRedis.password.secret.name -}}
redis://:$(REDIS_PASSWORD)@{{ .Values.appflowy.externalRedis.host }}:{{ .Values.appflowy.externalRedis.port }}
{{- else -}}
redis://{{ .Values.appflowy.externalRedis.host }}:{{ .Values.appflowy.externalRedis.port }}
{{- end -}}
{{- end }}

{{- define "appflowy.baseUrl" -}}
https://{{ .Values.appflowy.baseFqdn }}
{{- end }}

{{- define "appflowy.baseWsUrl" -}}
wss://{{ .Values.appflowy.baseFqdn }}/ws/v2
{{- end }}
