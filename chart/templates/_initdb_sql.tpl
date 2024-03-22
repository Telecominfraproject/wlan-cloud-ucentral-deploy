{{- define "openwifi.user_creation_script_sql" -}}
{{- $root := . -}}
{{- $postgresqlBase := index .Values "postgresql" }}
{{- $postgresqlEmulatedRoot := (dict "Values" $postgresqlBase "Chart" (dict "Name" "postgresql") "Release" $.Release) }}
{{ range index .Values "postgresql" "initDbScriptSecret" "services" }}
CREATE USER {{ index $root "Values" . "configProperties" "storage.type.postgresql.username" }};
ALTER USER {{ index $root "Values" . "configProperties" "storage.type.postgresql.username" }} WITH ENCRYPTED PASSWORD '{{ index $root "Values" . "configProperties" "storage.type.postgresql.password" }}';
CREATE DATABASE {{ index $root "Values" . "configProperties" "storage.type.postgresql.database" }};
GRANT ALL PRIVILEGES ON DATABASE {{ index $root "Values" . "configProperties" "storage.type.postgresql.database" }} TO {{ index $root "Values" . "configProperties" "storage.type.postgresql.username" }};
ALTER DATABASE {{ index $root "Values" . "configProperties" "storage.type.postgresql.database" }} OWNER TO {{ index $root "Values" . "configProperties" "storage.type.postgresql.username" }};
{{ end }}
{{- end -}}

