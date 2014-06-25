#!/bin/bash
# created by: charles akalugwu <charles@lieferando.de>
# since: 25.06.2014

# stop nginx

	sudo service nginx stop
		
# copy the contents of the conf folder to /usr/local/nginx/conf

	sudo cp -R /vagrant/conf/* /usr/local/nginx/conf/

# copy the contents of the html folder to /usr/local/nginx/html

	sudo cp -R /vagrant/html/* /usr/local/nginx/html/
	
# start nginx

	sudo service nginx start