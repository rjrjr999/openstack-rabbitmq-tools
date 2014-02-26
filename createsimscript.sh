#!/bin/sh
# The script will create scripts used to simulate Nova VM instance creation 
# and deletion messages for consumption by OpenStack Designate.

USER=$1
PASSWORD=$2
TENANT=$3
HOSTNAME=$4
IPADDRESS=$5

# Modify these variables for the local environment.
export OS_USERNAME=admin
export OS_PASSWORD=changeme
export OS_TENANT_NAME=admin
export OS_AUTH_URL="http://localhost:5000/v2.0/"
export OS_AUTH_STRATEGY=keystone
URI=amqp://localhost:5672/
EXCHANGE=nova
ROUTINGKEY=monitor.info

USERID=`keystone user-list | grep $USER | awk '{print $2}'`
TENANTID=`keystone tenant-list | grep $TENANT | awk '{print $2}'`

export OS_USERNAME=$USER
export OS_PASSWORD=$PASSWORD
export OS_TENANT_NAME=$TENANT

TOKEN=`keystone token-get | grep " id " | awk '{print $4}'`
if [ $USER == 'admin' ] ; then
    ISADMIN=True
    ROLES="['admin']"
else
    ISADMIN=False
    ROLES="None"
fi

THISTIMESTAMP=`date -u '+%FT%T.%N'`
THISHOSTNAME=`hostname`
THISIPADDRESS=`host $THISHOSTNAME | awk '{print $4}'`
CREATEREQUESTID=req-`uuidgen -r`
DELETEREQUESTID=req-`uuidgen -r`
INSTANCEID=`uuidgen -t`
CREATEMESSAGEID=`uuidgen -r`
DELETEMESSAGEID=`uuidgen -r`
CREATEBODY="{'_context_roles': $ROLES, '_context_request_id': '$CREATEREQUESTID', '_context_quota_class': None, 'event_type': 'compute.instance.create.end', '_context_service_catalog': [], 'timestamp': '$THISTIMESTAMP', '_context_timestamp': '$THISTIMESTAMP', '_unique_id': '6ef0456ed71646abb7da76880750fd7f', '_context_instance_lock_checked': False, '_context_user_id': '$USERID', 'payload': {'state_description': '', 'availability_zone': None, 'terminated_at': '', 'ephemeral_gb': 0, 'instance_type_id': 2, 'message': 'Success', 'deleted_at': '', 'reservation_id': 'r-0fhyl6wq', 'instance_id': '$INSTANCEID', 'user_id': '$USERID', 'fixed_ips': [{'floating_ips': [], 'label': 'private', 'version': 4, 'meta': {}, 'address': '$IPADDRESS', 'type': 'fixed'}], 'hostname': '$HOSTNAME', 'state': 'active', 'launched_at': '$THISTIMESTAMP', 'metadata': [], 'node': '$THISHOSTNAME', 'ramdisk_id': '', 'access_ip_v6': None, 'disk_gb': 1, 'access_ip_v4': None, 'kernel_id': '', 'image_name': 'cirros-0.3.0-x86_64-disk', 'host': '$THISHOSTNAME', 'display_name': '$HOSTNAME', 'image_ref_url': 'http://192.168.56.35:9292/images/afd10e78-d2e2-41cf-b1f7-573d7c89ac18', 'root_gb': 1, 'tenant_id': '$TENANTID', 'created_at': '$THISTIMESTAMP', 'memory_mb': 512, 'instance_type': 'm1.tiny', 'vcpus': 1, 'image_meta': {'min_disk': '1', 'container_format': 'bare', 'min_ram': '0', 'disk_format': 'qcow2', 'base_image_ref': 'afd10e78-d2e2-41cf-b1f7-573d7c89ac18'}, 'architecture': None, 'os_type': None, 'instance_flavor_id': '1'}, '_context_project_name': '$TENANT', '_context_read_deleted': 'no', '_context_auth_token': '$TOKEN', '_context_tenant': '$TENANTID', 'priority': 'INFO', '_context_is_admin': $ISADMIN, '_context_project_id': '$TENANTID', '_context_user': '$USERID', '_context_user_name': '$USER', 'publisher_id': 'compute.$THISHOSTNAME', 'message_id': '$CREATEMESSAGEID', '_context_remote_address': '$THISIPADDRESS'}"
DELETEBODY="{'_context_roles': $ROLES, '_context_request_id': '$DELETEREQUESTID', '_context_quota_class': None, 'event_type': 'compute.instance.delete.start', '_context_service_catalog': [], 'timestamp': '$THISTIMESTAMP', '_context_timestamp': '$THISTIMESTAMP', '_unique_id': 'f143b3540e9241a3b8826de87cb9c194', '_context_instance_lock_checked': False, '_context_user_id': '$USERID', 'payload': {'state_description': 'deleting', 'availability_zone': None, 'terminated_at': '', 'ephemeral_gb': 0, 'instance_type_id': 2, 'deleted_at': '', 'reservation_id': 'r-e6f4n0rl', 'instance_id': '$INSTANCEID', 'user_id': '$USERID', 'hostname': '$HOSTNAME', 'state': 'active', 'launched_at': '$THISTIMESTAMP', 'metadata': {}, 'node': '$THISHOSTNAME', 'ramdisk_id': '', 'access_ip_v6': None, 'disk_gb': 1, 'access_ip_v4': None, 'kernel_id': '', 'host': '$THISHOSTNAME', 'display_name': '$HOSTNAME', 'image_ref_url': 'http://192.168.56.35:9292/images/afd10e78-d2e2-41cf-b1f7-573d7c89ac18', 'root_gb': 1, 'tenant_id': '$TENANTID', 'created_at': '$THISTIMESTAMP', 'memory_mb': 512, 'instance_type': 'm1.tiny', 'vcpus': 1, 'image_meta': {'min_disk': '1', 'container_format': 'bare', 'min_ram': '0', 'disk_format': 'qcow2', 'base_image_ref': 'afd10e78-d2e2-41cf-b1f7-573d7c89ac18'}, 'architecture': None, 'os_type': None, 'instance_flavor_id': '1'}, '_context_project_name': '$TENANT', '_context_read_deleted': 'no', '_context_auth_token': '$TOKEN', '_context_tenant': '$TENANTID', 'priority': 'INFO', '_context_is_admin': $ISADMIN, '_context_project_id': '$TENANTID', '_context_user': '$USERID', '_context_user_name': '$USER', 'publisher_id': 'compute.$THISHOSTNAME', 'message_id': '$DELETEMESSAGEID', '_context_remote_address': '$THISIPADDRESS'}"

SCRIPT=simnova_$HOSTNAME.sh

(cat <<+
#!/bin/bash
# Simulate nova VM creation/deletion for $HOSTNAME/$IPADDRESS ($INSTANCEID).
# This script was autogenerated by $0.

PROG="python amqppublisher.py"
ARGS="--uri=$URI --exchange=$EXCHANGE --key=$ROUTINGKEY"
case \$1 in
create)
    \$PROG \$ARGS --body="$CREATEBODY"
    ;;
delete)
    \$PROG \$ARGS --body="$DELETEBODY"
    ;;
*)
    echo "\$0 create | delete"
esac

exit 0
+
) > $SCRIPT

chmod u+x $SCRIPT
