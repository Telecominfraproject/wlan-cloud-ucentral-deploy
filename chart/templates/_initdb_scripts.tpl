{{- define "openwifi.user_creation_script" -}}
{{- $root := . -}}
{{- $postgresqlBase := .Values.postgresql }}
{{- $postgresqlEmulatedRoot := (dict "Values" $postgresqlBase "Chart" (dict "Name" "postgresql") "Release" $.Release) }}
#!/bin/bash
export PGPASSWORD=postgres

echo "Testing if postgres is running before executing the initialization script."

until pg_isready -h postgresql -p 5432; do echo "Postgres is unavailable - sleeping"; sleep 2; done;

echo "Postgres is running, executing initialization script."

echo "CREATE USER owgw " | psql -h postgresql postgres postgres

echo "Postgres has been initialized."

{{- end -}}
