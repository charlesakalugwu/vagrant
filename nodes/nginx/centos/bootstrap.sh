#!/bin/bash
# created by: charles akalugwu <charles@lieferando.de>
# since: 25.06.2014

# create installation temp folder

	sudo mkdir ~/nginx.installation
	cd ~/nginx.installation

#start by creating a system user for the nginx service to use (including home directory)

	sudo useradd -rm nginx
	echo -e 'nginxvagrant\nnginxvagrant\n' | sudo passwd nginx

#installl GNU Development Tools (for compilers, make and stuff like that)

	yum -y groupinstall "Development Tools"

#get nginx distribution

	sudo wget http://nginx.org/download/nginx-1.6.0.tar.gz
	sudo tar xvf nginx-1.6.0.tar.gz
	sudo rm nginx-1.6.0.tar.gz

#get zlib library

	sudo wget http://zlib.net/zlib-1.2.8.tar.gz
	sudo tar xvf zlib-1.2.8.tar.gz
	sudo rm zlib-1.2.8.tar.gz

#download pcre 8.36

	sudo wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.36.tar.gz
	sudo tar xfz pcre-8.36.tar.gz
	sudo rm pcre-8.36.tar.gz

#download openssl 1.0.1g

	sudo wget http://www.openssl.org/source/openssl-1.0.1g.tar.gz
	sudo tar xfz openssl-1.0.1g.tar.gz
	sudo rm openssl-1.0.1g.tar.gz
	
# download HttpHeadersMore nginx module v0.25

	sudo wget https://github.com/openresty/headers-more-nginx-module/archive/v0.25.tar.gz
	sudo tar xfz v0.25.tar.gz
	sudo rm v0.25.tar.gz

#go into the nginx directory
	cd nginx-1.6.0/

#configure the installation with the dependencies
	sudo ./configure --with-debug --user=nginx --group=nginx --with-pcre=../pcre-8.36/ --with-zlib=../zlib-1.2.8/ --with-http_ssl_module --with-openssl=../openssl-1.0.1g/ --add-module=../headers-more-nginx-module-0.25

#run make and make install

	sudo make
	sudo make install
	
# delete the temporary install folder
	cd
	sudo rm -rf ~/nginx.installation
	
	
# install the nginx startup script
	
	wget -O /etc/init.d/nginx https://raw.githubusercontent.com/charleslieferando/vagrant/master/nodes/nginx/centos/nginx-startup-script.sh
	
# make the script executable

	sudo chmod +x /etc/init.d/nginx

# enable nginx to run as a service

	sudo chkconfig nginx on

# confirm all is well with the service addition

	sudo chkconfig --list nginx

# start the service

	sudo service nginx start
	
# Setup iptables rules

	sudo iptables -F
	sudo iptables -I INPUT -j ACCEPT
	service iptables save
	sudo iptables -L -nv
