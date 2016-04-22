#!/bin/bash
# author tonynv@amazon.com
# Install Ansible Tower
#

USERDATAID=ansible_install
QS_DEPLOY_ROOT=/root
DATE=`date +%d-%m-%Y`

######################################################################
#Source Files
######################################################################
ANSIBLE_SOURCE="https://releases.ansible.com/ansible-tower/setup-bundle"
#ANSIBLE_SOURCE_FILE="ansible-tower-setup-bundle-2.4.4-1.el7.tar.gz"
ANSIBLE_SOURCE_FILE="ansible-tower-setup-bundle-latest.el7.tar.gz"

date >/root/install_date
echo "Installing Tools"
# Install tools needed for bootstraping
yum install wget -y
yum install ansible -y


######################################################################
# Install Ansible Tower
######################################################################
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

# Make file only readable by root
chmod 400 /etc/qsrdsinfo.conf
chmod 400 /etc/qsadmin.conf
RDSINFO="/etc/qsrdsinfo.conf"
ADMINFO="/etc/qsadmin.conf"

##############################################################
# Pass Cloudformation Parms to Tower installer (then delete)
##############################################################
if [ -f $ADMININFO ] ; then
ANSIBLE_ADMIN_PASSWD=`cat $ADMINFO| grep ansible_admin_password | awk -F"|" '{print $2}'`
ANSIBLE_DBADMIN_PASSWD=`cat $ADMINFO| grep ansible_dbadmin_password | awk -F"|" '{print $2}'`
fi

echo "Create tower_setup yml"

#Create tower_setup yml
cat <<EOF >> tower_setup_conf.yml 
admin_password: ${ANSIBLE_ADMIN_PASSWD} 
configure_private_vars: {}
database: internal
munin_password: ${ANSIBLE_ADMIN_PASSWD}
pg_password: ${ANSIBLE_DBADMIN_PASSWD}
primary_machine: localhost
redis_password: ${ANSIBLE_DBADMIN_PASSWD}

EOF


echo "Create tower_setup yml"
#Create inventory file
cat <<EOF >> inventory
[primary]
localhost

[all:vars]
EOF

#############################################################
# Start Tower Setup
#############################################################
./setup.sh

# Remove files used in bootstraping
rm /etc/qsrdsinfo.conf
rm /etc/qsansible.conf

echo "Finished AWSQuickStart Bootstraping"

