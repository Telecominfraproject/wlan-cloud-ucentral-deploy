{{- define "openwifi.user_creation_script" -}}
{{- $root := . -}}
{{- $postgresqlBase := index .Values "postgresql-ha" }}
{{- $postgresqlEmulatedRoot := (dict "Values" $postgresqlBase "Chart" (dict "Name" "postgresql-ha") "Release" $.Release) }}
#!/bin/bash
export PGPASSWORD=$PGPOOL_POSTGRES_PASSWORD

until psql -h {{ include "postgresql-ha.postgresql" $postgresqlEmulatedRoot }} postgres postgres -c '\q'; do
  >&2 echo "Postgres is unavailable - sleeping"
  sleep 1
done

{{ range index .Values "postgresql-ha" "initDbScriptSecret" "services" }}
echo "{{ . }}"
echo "SELECT 'CREATE USER {{ index $root "Values" . "configProperties" "storage.type.postgresql.username" }}' WHERE NOT EXISTS (SELECT FROM pg_user WHERE usename = '{{ index $root "Values" . "configProperties" "storage.type.postgresql.username" }}')\gexec" | psql -h {{ include "postgresql-ha.postgresql" $postgresqlEmulatedRoot }} postgres postgres
echo "ALTER USER {{ index $root "Values" . "configProperties" "storage.type.postgresql.username" }} WITH ENCRYPTED PASSWORD '{{ index $root "Values" . "configProperties" "storage.type.postgresql.password" }}'" | psql -h {{ include "postgresql-ha.postgresql" $postgresqlEmulatedRoot }} postgres postgres
echo "SELECT 'CREATE DATABASE {{ index $root "Values" . "configProperties" "storage.type.postgresql.database" }}' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '{{ index $root "Values" . "configProperties" "storage.type.postgresql.database" }}')\gexec" | psql -h {{ include "postgresql-ha.postgresql" $postgresqlEmulatedRoot }} postgres postgres
echo "GRANT ALL PRIVILEGES ON DATABASE {{ index $root "Values" . "configProperties" "storage.type.postgresql.database" }} TO {{ index $root "Values" . "configProperties" "storage.type.postgresql.username" }}" | psql -h {{ include "postgresql-ha.postgresql" $postgresqlEmulatedRoot }} postgres postgres

{{ end }}
{{- end -}}
