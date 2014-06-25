#!/bin/bash
# created by: charles akalugwu <charles@lieferando.de>
# since: 19.06.2014        

# Install Java if it is not installed

	sudo yum remove java
	sudo yum -y install java-1.6.0-openjdk wget
	java -version

# Install Jenkins
	
	sudo cp /vagrant/jenkins.repo /etc/yum.repos.d/jenkins.repo
	sudo rpm --import /vagrant/jenkins-ci.org.key
	sudo yum -y update
	sudo yum -y install jenkins
	chkconfig jenkins on
	sudo service jenkins start
	
	if [ ! -f /tmp/jenkins.plugins.tar.gz ]
	then
	   wget -O /tmp/jenkins.plugins.tar.gz https://www.dropbox.com/s/fct46u6rmg7akzc/jenkins.plugins.tar.gz?dl=1
	fi
	
	tar xvf /tmp/jenkins.plugins.tar.gz
	sudo cp ./jenkins.plugins/* /var/lib/jenkins/plugins
	sudo service jenkins restart
	sudo netstat -nlp | grep :8080
	
# Setup iptables rules

	iptables -F
	sudo iptables -I INPUT -j ACCEPT
	service iptables save
	iptables -L -nv
