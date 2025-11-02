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

{{- define "affine.privateKey" -}}
{{- include "affine.secretOrValue" (dict "config" .Values.affine.secret.privateKey "context" .) }}
{{- end }}

{{- define "affine.dbUsername" -}}
{{- include "affine.secretOrValue" (dict "config" .Values.affine.externalDatabase.username "context" .) }}
{{- end }}

{{- define "affine.dbPassword" -}}
{{- include "affine.secretOrValue" (dict "config" .Values.affine.externalDatabase.password "context" .) }}
{{- end }}

{{- define "affine.redisPassword" -}}
{{- include "affine.secretOrValue" (dict "config" .Values.affine.externalRedis.password "context" .) }}
{{- end }}

{{- define "affine.indexerApiKey" -}}
{{- include "affine.secretOrValue" (dict "config" .Values.affine.indexer.apiKey "context" .) }}
{{- end }}

{{- define "affine.smtpHost" -}}
{{- include "affine.secretOrValue" (dict "config" .Values.smtp.host "context" .) }}
{{- end }}

{{- define "affine.smtpPort" -}}
{{- include "affine.secretOrValue" (dict "config" .Values.smtp.port "context" .) }}
{{- end }}

{{- define "affine.smtpUser" -}}
{{- include "affine.secretOrValue" (dict "config" .Values.smtp.user "context" .) }}
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
postgres://$(DB_USERNAME):$(DB_PASSWORD)@{{ .Values.affine.externalDatabase.host }}:{{ .Values.affine.externalDatabase.port }}/{{ .Values.affine.externalDatabase.database }}
{{- end -}}
{{- end }}

{{- define "affine.baseUrl" -}}
https://{{ .Values.affine.baseFqdn }}
{{- end }}

{{- define "affine.baseWsUrl" -}}
wss://{{ .Values.affine.baseFqdn }}
{{- end }}
