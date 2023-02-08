psql -v ON_ERROR_STOP=1 cordacluster <<-EOF
  do
  \$\$
  BEGIN
    IF NOT EXISTS (SELECT * FROM pg_user WHERE usename = 'corda') THEN
       CREATE ROLE "corda" PASSWORD '$USER_PASSWORD' NOSUPERUSER CREATEDB CREATEROLE INHERIT LOGIN;
       GRANT CREATE ON DATABASE cordacluster TO "corda";
    END IF;
  END
  \$\$
  ;
EOF