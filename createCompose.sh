# Set variables for environment if not present
export ENV_PATH="./.env"

# $COMPOSE_YAML, $DB_VERSION, $IMAGE_NAME, $DG_DIR, $ORADATA_VOLUME
set -a
. $ENV_PATH
set +a

# Create a docker-compose file and dynamically build the tnsnames.ora file
# Initialize the docker-compose file:
cat << EOF > $COMPOSE_YAML
version: '3'
services: 
EOF

# Initialize the TNSNames file:
cat << EOF > $DG_DIR/tnsnames.ora
# tnsnames.ora extension for Data Guard demo
EOF

# Populate the docker-compose.yml file:
egrep -v "^$|^#" $DG_DIR/config_dataguard.lst | sed -e 's/[[:space:]]//g' | sort | while IFS='|' read CONTAINER_NAME CONTAINER_ID ROLE DG_CONFIG ORACLE_SID DB_UNQNAME DG_TARGET ORACLE_PWD 
do

# Write the Docker compose file entry:
cat << EOF >> $COMPOSE_YAML
  $CONTAINER_NAME:
    image: \${IMAGE_NAME}
    container_name: $CONTAINER_NAME
    volumes:
      - "\${ORADATA_VOLUME}/$CONTAINER_NAME:/opt/oracle/oradata"
      - "\${DG_DIR}:/opt/oracle/scripts"
    environment:
      CONTAINER_NAME: $CONTAINER_NAME
      DG_CONFIG: $DG_CONFIG
      DG_TARGET: $DG_TARGET
      ORACLE_PDB: ${ORACLE_SID}PDB1
      ORACLE_PWD: $ORACLE_PWD
      ORACLE_SID: $ORACLE_SID
      DB_UNQNAME: $DB_UNQNAME
      ROLE: $ROLE
    ports:
      - "121$CONTAINER_ID:1521"

EOF

# Write a tnsnames.ora entry for each instance in the configuration file:
cat << EOF >> $DG_DIR/tnsnames.ora
$CONTAINER_NAME=
(DESCRIPTION =
  (ADDRESS = (PROTOCOL = TCP)(HOST = $CONTAINER_NAME)(PORT = 1521))
  (CONNECT_DATA =
    (SERVER = DEDICATED)
    (SID = $ORACLE_SID)
  )
)
EOF

done

