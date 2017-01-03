#!/usr/bin/env bash

# Provisioning script to get as close as possible to the Rackspace Cloud Sites configuration.

CYAN='\033[0;36m'
NC='\033[0m' # No Color
printf "\n\n${CYAN}-=-=-= Begin Provision Script =-=-=-${NC}\n"

sudo apt-get update

sudo timedatectl set-timezone America/Chicago


printf "\n${CYAN}-=-=-= Install Common Programs =-=-=-${NC}\n"

sudo apt-get install -y software-properties-common linux-headers-$(uname -r) build-essential dkms python-software-properties vim curl wget unzip

# Commented out in favor of the vagrant-vbguest plugin
# printf "\n${CYAN}-=-=-= Install Guest Additions =-=-=-${NC}\n"
# wget http://download.virtualbox.org/virtualbox/5.1.12/VBoxGuestAdditions_5.1.12.iso
# sudo mkdir /media/VBoxGuestAdditions
# sudo mount -o loop,ro VBoxGuestAdditions_5.1.12.iso /media/VBoxGuestAdditions
# sudo sh /media/VBoxGuestAdditions/VBoxLinuxAdditions.run
# rm VBoxGuestAdditions_5.1.12.iso
# sudo umount /media/VBoxGuestAdditions
# sudo rmdir /media/VBoxGuestAdditions


printf "\n${CYAN}-=-=-= Install MariaDB 10.0 =-=-=-${NC}\n"

# import and register the key to verify downloads
sudo apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xcbcb082a1bb943db

# add repo for MariaDB 10.0
sudo add-apt-repository 'deb [arch=amd64,i386,ppc64el] http://ftp.osuosl.org/pub/mariadb/repo/10.0/debian jessie main'

# configuration to install MariaDB 10.0 without password prompt, setting root password to 'root'
export DEBIAN_FRONTEND=noninteractive
debconf-set-selections <<< 'mariadb-server-10.0 mysql-server/root_password password root'
debconf-set-selections <<< 'mariadb-server-10.0 mysql-server/root_password_again password root'

# install MariaDB
sudo apt-get update
sudo apt-get install -y mariadb-server


printf "\n${CYAN}-=-=-= Install Apache 2 and PHP 5.6.29 =-=-=-${NC}\n"

# Rackspace uses PHP 5.6.24 but 5.6.29 should be close enough!
# install apache2 with php5 and other php dependencies, as well as other desired php features
sudo apt-get update
sudo apt-get install -y apache2 php5 libapache2-mod-php5 php5-common php5-mysqlnd

# turn off KeepAlive
sudo sed -i -e 's/KeepAlive On/KeepAlive Off/g' /etc/apache2/apache2.conf

# set server name
sudo sed -i '1 i\ServerName localhost' /etc/apache2/apache2.conf

# disable default vhost (you decide)
# sudo a2dissite 000-default.conf

# enable apache mods
sudo a2enmod authz_groupfile include expires headers rewrite actions unique_id remoteip
sudo service apache2 restart

# configure apache to run as vagrant
sed -i -e 's/export APACHE_RUN_USER=www-data/export APACHE_RUN_USER=vagrant/g' /etc/apache2/envvars
sed -i -e 's/export APACHE_RUN_GROUP=www-data/export APACHE_RUN_GROUP=vagrant/g' /etc/apache2/envvars
sudo chown vagrant /var/lock/apache2

# remove the default /var/www/html folder and link /vagrant folder to /var/www/html
if ! [ -L /var/www/html ]; then
	rm -rf /var/www/html
	ln -fs /vagrant /var/www/html
fi

sudo chown vagrant:vagrant /var/www/html
sudo chown vagrant:vagrant /var/www/vhosts

# install additional PHP modules

# ionCube - if you need it, uncomment these lines
#cd /tmp
#wget http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz
#tar xfz ioncube_loaders_lin_x86-64.tar.gz
#cp /tmp/ioncube/ioncube_loader_lin_5.6.so /usr/lib/php5/20131226/

# add ionCube to php.ini files (inserting as first line in these files)
#sed -i '1 i\zend_extension = /usr/lib/php5/20131226/ioncube_loader_lin_5.6.so' /etc/php5/apache2/php.ini
#sed -i '1 i\zend_extension = /usr/lib/php5/20131226/ioncube_loader_lin_5.6.so' /etc/php5/cli/php.ini

# Rackspace uses the Zend Guard Loader but let's pass on installing that for now because it's not straightforward and we probably won't use it ever.

# Rackspace PHP extensions
# There are a few that we have ignored for now because they require extra effort and we probably don't use them!
sudo apt-get install -y php5-curl php5-gd php5-gmp php5-imagick php5-imap php5-intl php5-ldap php5-mcrypt php5-memcache php5-mongo php5-mysql php5-odbc php5-pgsql php5-sqlite php5-sybase php5-pspell php5-recode php5-redis php5-svn php5-xmlrpc php5-xsl php5-tidy

# configure PHP
sed -i "s/register_argc_argv = Off/register_argc_argv = On/" /etc/php5/apache2/php.ini
sed -i "s/serialize_precision = 17/serialize_precision = 100/" /etc/php5/apache2/php.ini
sed -i "s/short_open_tag = Off/short_open_tag = On/" /etc/php5/apache2/php.ini
sed -i "s/;upload_tmp_dir =/upload_tmp_dir = \/tmp/" /etc/php5/apache2/php.ini
sed -i "s/variables_order = \"GPCS\"/variables_order = \"EGPCS\"/" /etc/php5/apache2/php.ini
sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 8M/" /etc/php5/apache2/php.ini
sed -i "s/;date.timezone =/date.timezone=\"America\/Chicago\"/" /etc/php5/apache2/php.ini
sed -i "s/mysql.allow_persistent = On/mysql.allow_persistent = Off/" /etc/php5/apache2/php.ini
sed -i "s/;session.entropy_length = 32/session.entropy_length = 0/" /etc/php5/apache2/php.ini

# turn on PHP error reporting (this is different from Rackspace for obvious reasons)
sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php5/apache2/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php5/apache2/php.ini

# download and install the vhost shortcut command
sudo wget -O /usr/local/bin/vhost https://gist.githubusercontent.com/fideloper/2710970/raw/5d7efd74628a1e3261707056604c99d7747fe37d/vhost.sh
sudo chmod guo+x /usr/local/bin/vhost

sudo service apache2 restart

printf "\n${CYAN}-=-=-= Provisioning Complete! Now make something awesome! =-=-=-${NC}\n"