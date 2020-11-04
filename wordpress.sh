#!/bin/bash -xe

yum update -y

#checks if amazon linux is v1 or v2
isl2=$(uname -a| grep amzn2)

if [ "isl2" != "" ]; then
	amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2
	yum install -y httpd mariadb-server
else
	yum install -y httpd24 php70 mysql56-server php70-mysqlnd
fi

groupadd www

usermod -aG www ec2-user

cd /var/www

curl -O https://wordpress.org/wordpress-5.1.1.tar.gz && tar -xzf wordpress-5.1.1.tar.gz


rm -rf /var/www/html

mv wordpress /var/www/html

chown -R root:apache /var/www

chmod 2775 /var/www

find /var/www -type d -exec chmod 2775 {} +
find /var/www -type f -exec chmod 0664 {} +

echo '<?php phpinfo(); ?>' > /var/www/html/phpinfo.php

service httpd start

chkconfig httpd on

if [ "$isl2" != "" ] ; then
	service mariadb start
	chkconfig mariadb on
else
	service mysqld start
	chkconfig mysql on	
fi
