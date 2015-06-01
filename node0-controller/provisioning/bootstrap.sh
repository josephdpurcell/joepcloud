#!/bin/bash
# Controller node provisioning.
DIR=$1

# Copy ntp config.
cp $DIR/ntp/ntp.conf /etc/ntp.conf
service ntp restart

# Install the db and python driver used by many OpenStack services.
# Can be MariaDB or MySQL.
DEBIAN_FRONTEND=noninteractive apt-get -y install mysql-server python-mysqldb
cp $DIR/mysql/my.cnf /etc/mysql/my.cnf
mysqladmin -u root password "pass"
service mysql restart

# Install a messaging system used by many OpenStack services.
# Can be RabbitMQ, Qpid, or ZeroMQ.
# Work around Ubuntu having outdated packages:
echo "deb http://www.rabbitmq.com/debian/ testing main" >> /etc/apt/sources.list
wget https://www.rabbitmq.com/rabbitmq-signing-key-public.asc
apt-key add rabbitmq-signing-key-public.asc
DEBIAN_FRONTEND=noninteractive apt-get -y update
# And, finally install:
DEBIAN_FRONTEND=noninteractive apt-get -y install rabbitmq-server
rabbitmqctl add_user openstack pass
rabbitmqctl set_permissions openstack ".*" ".*" ".*"

# Setup Identity service.
# Note: this is also referred to as Keystone.
# 1. Install keystone and dependencies.
#   a. Setup database.
SQL="CREATE DATABASE keystone;
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY 'pass';
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY 'pass';"
echo $SQL | mysql -u root -ppass
#   b. Prevent keystone from autostarting after install. @todo figure out why this is needed
echo "manual" > /etc/init/keystone.override
#   c. Install keystone and dependencies.
DEBIAN_FRONTEND=noninteractive apt-get -y install keystone python-openstackclient apache2 libapache2-mod-wsgi memcached python-memcache
#   d. Copy configuration for keystone.
cp $DIR/keystone/keystone.conf /etc/keystone/keystone.conf
#   e. Populate the Identity database.
su -s /bin/sh -c "keystone-manage db_sync" keystone
#   f. Because we are using MySQL in our config, we can delete the SQLLite db.
rm -f /var/lib/keystone/keystone.db
# 2. Configure Apache
cp $DIR/apache/apache2.conf /etc/apache2/apache2.conf
cp $DIR/apache/wsgi-keystone.conf /etc/apache2/sites-available/wsgi-keystone.conf
ln -s /etc/apache2/sites-available/wsgi-keystone.conf /etc/apache2/sites-enabled
mkdir -p /var/www/cgi-bin/keystone
curl http://git.openstack.org/cgit/openstack/keystone/plain/httpd/keystone.py?h=stable/kilo | tee /var/www/cgi-bin/keystone/main /var/www/cgi-bin/keystone/admin
# Note: this doesn't work inside a vm?
#chown -R keystone:keystone /var/www/cgi-bin/keystone
chmod 755 /var/www/cgi-bin/keystone/*
service apache2 restart
# 3. Register keystone service.
source $DIR/keystone/admin-temp-credentials.sh
openstack service create --name keystone --description "OpenStack Identity" identity
openstack endpoint create \
  --publicurl http://node0-controller.joepcloud.local:5000/v2.0 \
  --internalurl http://node0-controller.joepcloud.local:5000/v2.0 \
  --adminurl http://node0-controller.joepcloud.local:35357/v2.0 \
  --region RegionOne \
    identity
# 4. Create tenants, users, and roles.
#   a. Create admin project.
openstack project create --description "Admin Project" admin
openstack user create --password pass admin
openstack role create admin
openstack role add --project admin --user admin admin
#   b. Create service project.
openstack project create --description "Service Project" service
#   c. Create demo project.
openstack project create --description "Demo Project" demo
openstack user create --password pass demo
openstack role create user
openstack role add --project demo --user demo user

# Setup Image service.
# Note: this is also referred to as Glance.
# 1. Setup database.
SQL="CREATE DATABASE glance;
GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY 'pass';
GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY 'pass';"
echo $SQL | mysql -u root -ppass
# 2. Register glance with keystone.
unset OS_TOKEN OS_URL
source $DIR/keystone/admin-openrc.sh
openstack user create --password pass glance
openstack role add --project service --user glance admin
openstack service create --name glance --description "OpenStack Image service" image
openstack endpoint create \
  --publicurl http://node0-controller.joepcloud.local:9292 \
  --internalurl http://node0-controller.joepcloud.local:9292 \
  --adminurl http://node0-controller.joepcloud.local:9292 \
  --region RegionOne \
  image
# 3. Install service components.
DEBIAN_FRONTEND=noninteractive apt-get -y install glance python-glanceclient
cp $DIR/glance/glance-api.conf /etc/glance/glance-api.conf
cp $DIR/glance/glance-registry.conf /etc/glance/glance-registry.conf 
su -s /bin/sh -c "glance-manage db_sync" glance
# 4. Delete unused sqlite db since we use mysql in this setup.
rm -f /var/lib/glance/glance.sqlite
# 5. Restart glance
service glance-registry restart
service glance-api restart
# 6. Install an image.
mkdir /tmp/images
wget --quiet -P /tmp/images http://download.cirros-cloud.net/0.3.4/cirros-0.3.4-x86_64-disk.img
glance image-create --name "cirros-0.3.4-x86_64" --file /tmp/images/cirros-0.3.4-x86_64-disk.img --disk-format qcow2 --container-format bare --visibility public --progress
rm -r /tmp/images

touch /tmp/provisioned