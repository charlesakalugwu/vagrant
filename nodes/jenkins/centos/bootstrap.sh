#!/bin/bash
# created by: charles akalugwu <charles@lieferando.de>
# since: 19.06.2014        

# Install Java if it is not installed

	sudo yum -y remove java
	sudo yum -y install java-1.6.0-openjdk java-1.6.0-openjdk-devel wget
	java -version
	
# Install Maven
	if [ ! -f /tmp/apache-maven-3.2.1-bin.zip ]
	then
	   wget -O /tmp/apache-maven-3.2.1-bin.zip http://www.motorlogy.com/apache/maven/maven-3/3.2.1/binaries/apache-maven-3.2.1-bin.zip
	fi
	unzip /tmp/apache-maven-3.2.1-bin.zip
	sudo mv apache-maven-3.2.1/ /opt/maven/
	sudo ln -s /opt/maven/bin/mvn /usr/bin/mvn
	sudo cp /vagrant/maven.sh /etc/profile.d/maven.sh
	sudo chmod +x /etc/profile.d/maven.sh
	source /etc/profile.d/maven.sh
	mvn -version
	

# Install Jenkins
	
	sudo cp /vagrant/jenkins.repo /etc/yum.repos.d/jenkins.repo
	sudo rpm --import /vagrant/jenkins-ci.org.key
	sudo yum -y update
	sudo yum -y install jenkins
	chkconfig jenkins on
	sudo service jenkins start

# Install Jenkins plugins
	if [ ! -f /tmp/jenkins.plugins.tar.gz ]
	then
	   wget -O /tmp/jenkins.plugins.tar.gz https://www.dropbox.com/s/fct46u6rmg7akzc/jenkins.plugins.tar.gz?dl=1
	fi
	
	tar xvf /tmp/jenkins.plugins.tar.gz
	sudo cp ./jenkins.plugins/* /var/lib/jenkins/plugins
	sudo chown -R jenkins:jenkins /var/lib/jenkins/plugins/
	sudo rm -R ./jenkins.plugins
	
	
# Install Jenkins starter jobs
	if [ ! -f /tmp/jenkins.jobs.tar.gz ]
	then
	   wget -O /tmp/jenkins.jobs.tar.gz https://www.dropbox.com/s/4iviogni0svqogb/jenkins.jobs.tar.gz?dl=1
	fi
	
	tar xvf /tmp/jenkins.jobs.tar.gz
	sudo cp -R ./jenkins.jobs/* /var/lib/jenkins/jobs
	sudo chown -R jenkins:jenkins /var/lib/jenkins/jobs/
	sudo rm -R ./jenkins.jobs
	
	
# Setup github keys for jenkins

	sudo cp /vagrant/ssh/github/id_github_rsa /home/vagrant/.ssh/
	sudo chmod 600 /home/vagrant/.ssh/id_github_rsa
	sudo chown -R vagrant:vagrant /home/vagrant/.ssh/id_github_rsa
	sudo cp /vagrant/ssh/github/id_github_rsa.pub /home/vagrant/.ssh/
	sudo chmod 600 /home/vagrant/.ssh/id_github_rsa.pub
	sudo chown -R vagrant:vagrant /home/vagrant/.ssh/id_github_rsa.pub
	
	if [ ! -f /home/vagrant/.ssh/config ]
	then
	   sudo touch /home/vagrant/.ssh/config
	   sudo cat /vagrant/ssh/github/github_ssh_config >> /home/vagrant/.ssh/config
	   sudo chmod 600 /home/vagrant/.ssh/config
	   sudo chown -R vagrant:vagrant /home/vagrant/.ssh/config
	fi
	
	sudo service jenkins stop
	
	sudo mkdir /var/lib/jenkins/.ssh
	sudo cp /home/vagrant/.ssh/id_github_rsa /var/lib/jenkins/.ssh/id_github_rsa
	sudo chmod 600 /var/lib/jenkins/.ssh/id_github_rsa
	sudo chown -R jenkins:jenkins /var/lib/jenkins/.ssh/id_github_rsa
	sudo cp /home/vagrant/.ssh/id_github_rsa.pub /var/lib/jenkins/.ssh/id_github_rsa.pub
	sudo chmod 600 /var/lib/jenkins/.ssh/id_github_rsa.pub
	sudo chown -R jenkins:jenkins /var/lib/jenkins/.ssh/id_github_rsa.pub
	
	if sudo test -f "/var/lib/jenkins/.ssh/config"; then
	   echo "/var/lib/jenkins/.ssh/config file already exist, skipping this step..."
	else
		echo "/var/lib/jenkins/.ssh/config file does not exist, creating it now..."
		sudo touch /var/lib/jenkins/.ssh/config
	    sudo cp /vagrant/ssh/github/github_ssh_config /var/lib/jenkins/.ssh/config
	    sudo chmod 600 /var/lib/jenkins/.ssh/config
	    sudo chown -R jenkins:jenkins /var/lib/jenkins/.ssh/config
	fi
	
	sudo service jenkins start
	
	
# Setup iptables rules

	iptables -F
	sudo iptables -I INPUT -j ACCEPT
	service iptables save
	iptables -L -nv
