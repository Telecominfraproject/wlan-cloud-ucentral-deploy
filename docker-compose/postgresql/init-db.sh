#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
    CREATE USER $OWGW_DB_USER WITH ENCRYPTED PASSWORD '$OWGW_DB_PASSWORD';
    CREATE DATABASE $OWGW_DB OWNER $OWGW_DB_USER;
    CREATE USER $OWSEC_DB_USER WITH ENCRYPTED PASSWORD '$OWSEC_DB_PASSWORD';
    CREATE DATABASE $OWSEC_DB OWNER $OWSEC_DB_USER;
    CREATE USER $OWFMS_DB_USER WITH ENCRYPTED PASSWORD '$OWFMS_DB_PASSWORD';
    CREATE DATABASE $OWFMS_DB OWNER $OWFMS_DB_USER;
    CREATE USER $OWPROV_DB_USER WITH ENCRYPTED PASSWORD '$OWPROV_DB_PASSWORD';
    CREATE DATABASE $OWPROV_DB OWNER $OWPROV_DB_USER;
    CREATE USER $OWANALYTICS_DB_USER WITH ENCRYPTED PASSWORD '$OWANALYTICS_DB_PASSWORD';
    CREATE DATABASE $OWANALYTICS_DB OWNER $OWANALYTICS_DB_USER;
    CREATE USER $OWSUB_DB_USER WITH ENCRYPTED PASSWORD '$OWSUB_DB_PASSWORD';
    CREATE DATABASE $OWSUB_DB OWNER $OWSUB_DB_USER;
    \c owsec
    INSERT INTO users (id, name, description, avatar, email, validated, validationemail, validationdate, creationdate, validationuri, changepassword, lastlogin, currentloginuri, lastpasswordchange, lastemailcheck, waitingforemailcheck, locale, notes, location, owner, suspended, blacklisted, userrole, usertypeproprietaryinfo, securitypolicy, securitypolicychange, currentpassword, lastpasswords, oauthtype, oauthuserinfo, modified, signingup) VALUES ('11111111-0000-0000-6666-999999999999', 'Default User', 'Default user should be deleted.', '1701287135', 'tip@ucentral.com', true, '', 0, 1683468668, '', true, 1702156150, '', 1683468881, 0, false, '', '[]', '', '', false, false, 'root', '{"authenticatorSecret":"","mfa":{"enabled":false,"method":""},"mobiles":[]}', '', 0, '13268b7daa751240369d125e79c873bd8dd3bef7981bdfd38ea03dbb1fbe7dcf', '["13268b7daa751240369d125e79c873bd8dd3bef7981bdfd38ea03dbb1fbe7dcf","1683468881040646067|bcf145fa6354dbe1baddf1f66f6acc2466c49c2fbc22d2150a7f7a94fa1cfa27"]', '', '', '1683468881', '') ON CONFLICT (id) DO NOTHING;
EOSQL
