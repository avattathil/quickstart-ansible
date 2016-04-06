#!/bin/bash
# author tonynv@amazon.com
# Install ansible tower
#

USERDATAID=ansible_install
QS_DEPLOY_ROOT=/root
DATE=`date +%d-%m-%Y`

ANSIBLE_SOURCE="https://releases.ansible.com/ansible-tower/setup-bundle"
ANSIBLE_SOURCE_FILE="ansible-tower-setup-bundle-2.4.4-1.el7.tar.gz"

date >/root/install_date
echo "Installing Tools"
# Install tools needed for bootstraping
yum install wget -y

# Install Ansible Tower
echo "Installing Ansible Tower"
cd ${QS_DEPLOY_ROOT}
echo "Working in `pwd`" 
SRCURL=${ANSIBLE_SOURCE}/${ANSIBLE_SOURCE_FILE}
wget ${SRCURL} 

echo "Extract"
#Extract src_files
tar -zxvf ${ANSIBLE_SOURCE_FILE}

# Move into source dir
cd ansible-tower-setup*

# Relax the min var requirements
sed -i -e "s/10000000000/100000000/" roles/preflight/defaults/main.yml
# Allow sudo with out tty
sed -i -e "s/Defaults    requiretty/Defaults    \!requiretty/" /etc/sudoers

chmod 400 /etc/qsrdsinfo.conf
chmod 400 /etc/qsadmin.conf
RDSINFO="/etc/qsrdsinfo.conf"
ADMINFO="/etc/qsadmin.conf"

if [ -f $ADMININFO ] ; then
ANSIBLE_ADMIN_PASSWD=`cat $ADMINFO| grep ansible_admin_password | awk -F"|" '{print $2}'`
ANSIBLE_DBADMIN_PASSWD=`cat $ADMINFO| grep ansible_dbadmin_password | awk -F"|" '{print $2}'`
fi

if [ -f $RDSINFO ] ; then
echo "Using AWS RDS"
RDS_DBNAME=`cat $RDSINFO | grep rds_dbname | awk -F"|" '{print $2}'`
RDS_USER=`cat $RDSINFO | grep rds_user | awk -F"|" '{print $2}'`
RDS_PASS=`cat $RDSINFO | grep rds_pass | awk -F"|" '{print $2}'`
RDS_EP=`cat $RDSINFO| grep rds_endpoint | awk -F"|" '{print $2}'`
	
#Create tower_setup yml
cat <<EOF >> tower_setup_conf.yml
admin_password: ${ANSIBLE_ADMIN_PASSWD}
configure_private_vars: {}
database: external
mongo: false
munin_password: ${ANSIBLE_ADMIN_PASSWD}
pg_database: ${RDS_DBNAME}
pg_host: ${RDS_EP}
pg_password: ${RDS_PASS}
pg_port: 5432
pg_username: ${RDS_USER}
primary_machine: ${RDS_EP}
redis_password: ${ANSIBLE_ADMIN_PASSWD}

EOF

else

#Create tower_setup yml
cat <<EOF >> tower_setup_conf.yml 
admin_password: ${ANSIBLE_ADMIN_PASSWD} 
configure_private_vars: {}
database: internal
munin_password: ${ANSIBLE_ADMIN_PASSWD}
pg_password: ${ANSIBLE_DBADMIN_PASSWD}
primary_machine: localhost
redis_password: ${ANSIBLE_ADMIN_PASSWD}

EOF

fi

#Create inventory file
cat <<EOF >> inventory
[primary]
localhost

[all:vars]
EOF

./setup.sh

# Remove Userdata Info
#rm /etc/qsrdsinfo.conf
#rm /etc/qsansible.conf
