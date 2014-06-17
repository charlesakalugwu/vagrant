#!/bin/bash          

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
	sudo netstat -nlp | grep :8080
	
# Setup iptables rules
	
	iptables -A INPUT -s 192.168.0.0/24 -p tcp --dport 8080 -j ACCEPT
	service iptables save
	iptables -L -nv
