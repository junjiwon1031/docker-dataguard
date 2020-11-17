# export DG_DIR="${DG_DIR:-$(pwd)}"
# export ORADATA_VOLUME="${ORADATA_VOLUME:-${DG_DIR}/oradata}"
export ENV_PATH="./.env"

set -a
. $ENV_PATH
set +a

# Get sudo rights
export brand="Docker Volume Creater"
if [ "$(id -nu)" != "root"  ]; then
        sudo -k
            pass=$(whiptail --backtitle "$brand" --title "Authentication required" --passwordbox "$brand requires administrative privilege. Please authenticate to begin the installation.\n\n[sudo] Password for user $USER:" 12 50 3>&2 2>&1 1>&3-)
                exec sudo -S -p '' "$0" "$@" <<< "$pass"
                    exit 1
fi
echo ""

# Create ORADATA_VOLUME
echo "Creating ORADATA_VOLUME..."
[ ! -d ${ORADATA_VOLUME} ] && mkdir $ORADATA_VOLUME

cd $ORADATA_VOLUME

# Create directories for conatiners.
echo "Creating direcotries for conatiners ..."
egrep -v "^$|^#" $DG_DIR/config_dataguard.lst | sed -e 's/[[:space:]]//g' | sort | while IFS='|' read CONTAINER_NAME CONTAINER_ID ROLE DG_CONFIG ORACLE_SID DB_UNQNAME DG_TARGET ORACLE_PWD 
do

[ ! -d ${CONTAINER_NAME} ] && mkdir $CONTAINER_NAME

# Change owner to 'oracle' in the container.
echo "Change owner of $CONTAINER_NAME to 'oracle' in the container."
sudo chown 54321:54321 $CONTAINER_NAME
sudo chmod 777 $CONTAINER_NAME
done

echo "createDirectory.sh Done"
