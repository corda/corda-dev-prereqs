psql -v ON_ERROR_STOP=1 {{ .Values.postgresql.database }} <<-EOF
  do
  \$\$
  BEGIN
    IF NOT EXISTS (SELECT * FROM pg_user WHERE usename = '{{ .Values.postgresql.username }}') THEN
       CREATE ROLE "{{ .Values.postgresql.username }}" PASSWORD '$USER_PASSWORD' NOSUPERUSER CREATEDB CREATEROLE INHERIT LOGIN;
       GRANT CREATE ON DATABASE {{ .Values.postgresql.database }} TO "{{ .Values.postgresql.username }}";
    END IF;
  END
  \$\$
  ;
EOF