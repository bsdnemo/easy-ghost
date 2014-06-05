#!/bin/bash

#ghost blog install script
#author mayi
#email bsdnemo@gmail.com
#url http://github.com/bsdnemo/easy-ghost
#license GNU/GPL v2

# install requirement
install_requirement()
{
	unzip -v || apt-get -y install unzip
}

# check current user 
is_root()
{
	if [ $(whoami) != root ]; then
		return 1
	fi
}

# install node from debian backports
install_node()
{
	echo "deb http://ftp.us.debian.org/debian wheezy-backports main" >> /etc/apt/sources.list
	apt-get update
	apt-get -y install nodejs-legacy
	curl -k https://www.npmjs.org/install.sh | bash
}

# install forever module
install_forever()
{
	/usr/local/bin/npm install -g forever
}

# install ghost
install_ghost()
{
	mkdir -p /var/www
	cd /var/www
	wget -c http://ghost.org/zip/ghost-latest.zip
	unzip -d ghost ghost-latest.zip
	rm ghost-latest.zip
	cd ghost
	npm install --production
}

# edit ghost config
edit_ghost_config()
{
	sed -e 's/2368/80/' -e 's/127.0.0.1/0.0.0.0/' /var/www/ghost/config.example.js >/var/www/ghost/config.js
}

# install start up script
install_start_script()
{
	cat <<-_EOF_ >/usr/local/bin/ghoststart.sh
	#!/bin/bash
	export NODE_ENV=production
	forever -a -l /var/log/ghost --sourceDir /var/www/ghost start index.js
	_EOF_
	chmod u+x /usr/local/bin/ghoststart.sh
	echo "@reboot /usr/local/bin/ghoststart.sh" >>/etc/crontab
	/usr/local/bin/ghoststart.sh
}

# main 
is_root
if [ $? -eq 1 ] ; then
	echo "This script must be run as root"
	exit 1
fi

#install_requirement
install_node
install_forever
install_ghost
edit_ghost_config
install_start_script
echo "ghost has started."
exit
