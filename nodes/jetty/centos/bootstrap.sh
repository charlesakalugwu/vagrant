#!/bin/bash          

# Install Java if it is not installed

	sudo yum remove java
	sudo yum -y install java-1.7.0-openjdk java-1.7.0-openjdk-devel wget
	java -version
	
	sudo touch /etc/profile.d/java.sh
	sudo chown vagrant:vagrant /etc/profile.d/java.sh 
	sudo echo "export JRE_HOME=/usr/lib/jvm/jre-1.7.0" >> /etc/profile.d/java.sh
	sudo echo "export PATH=${JRE_HOME}/bin:${PATH}" >> /etc/profile.d/java.sh
	sudo echo "export JAVA_HOME=/usr/lib/jvm/java-1.7.0" >> /etc/profile.d/java.sh
	sudo echo "export PATH=${JAVA_HOME}/bin:${PATH}" >> /etc/profile.d/java.sh
	chmod u+x /etc/profile.d/java.sh
	/bin/bash /etc/profile.d/java.sh
	
# Download and install Jetty 9 (stable)
	
	cd /opt
	sudo wget http://ftp-stud.fht-esslingen.de/pub/Mirrors/eclipse/jetty/stable-9/dist/jetty-distribution-9.2.1.v20140609.tar.gz
	sudo tar xvf jetty-distribution-9.2.1.v20140609.tar.gz
	sudo rm -R jetty
	sudo mv jetty-distribution-9.2.1.v20140609 jetty
	sudo useradd jetty
	sudo chown -R jetty:jetty /opt/jetty
	sudo cp /vagrant/jetty.sh /etc/init.d/jetty
    
    # link build script
	ln -nfs /vagrant/deploy.sh /home/vagrant/deploy.sh
	ln -nfs /vagrant/context.xml /home/vagrant/context.xml
	
	ln -nfs /vagrant/ssh/id_github_rsa ~/.ssh/id_github_rsa
	ln -nfs /vagrant/ssh/id_github_rsa.pub ~/.ssh/id_github_rsa.pub
	exec ssh-agent /bin/bash
	ssh-add ~/.ssh/id_github_rsa
	


	sudo chkconfig --add jetty
	sudo chkconfig jetty on
	sudo service jetty start
	sudo rm jetty-distribution-9.2.1.v20140609.tar.gz
	
	sudo netstat -nlp | grep :80
	
	
# Install Maven 3
	cd /usr/local
	sudo wget http://ftp.fau.de/apache/maven/maven-3/3.2.1/binaries/apache-maven-3.2.1-bin.tar.gz
	sudo tar xvf apache-maven-3.2.1-bin.tar.gz
	sudo rm -r maven
	sudo mv apache-maven-3.2.1 maven
	sudo touch /etc/profile.d/maven.sh
	sudo chown vagrant:vagrant /etc/profile.d/maven.sh 
	sudo echo "export M2_HOME=/usr/local/maven" >> /etc/profile.d/maven.sh
	sudo echo "export PATH=${M2_HOME}/bin:${PATH}" >> /etc/profile.d/maven.sh
	sudo rm apache-maven-3.2.1-bin.tar.gz
	chmod u+x /etc/profile.d/maven.sh
	/bin/bash /etc/profile.d/maven.sh
	cd
	
# Setup iptables rules

	sudo iptables -F
	sudo iptables -I INPUT -j ACCEPT
	service iptables save
	sudo iptables -L -nv
	
	
# Deploy the API from master
	cd /home/vagrant

	sudo /bin/bash deploy.sh -e vagrant -v master -b master
