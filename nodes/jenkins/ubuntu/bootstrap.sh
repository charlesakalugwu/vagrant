#!/bin/bash          

# Install Java

	sudo apt-get -y install openjdk-7-jre openjdk-7-jdk wget 
	java -version

# Install Jenkins
	
	wget -q -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -
	sudo sh -c 'echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list'
	sudo apt-get -y update
	sudo apt-get -y install jenkins
	sudo service jenkins start
	sudo netstat -nlp | grep :8080
	
