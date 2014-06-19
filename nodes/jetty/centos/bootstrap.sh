#!/bin/bash          

# Install Java if it is not installed

	sudo yum -y remove java
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
	sudo rm -rf ./jetty
	sudo mv jetty-distribution-9.2.1.v20140609 jetty
	sudo useradd jetty
	sudo chown -R jetty /opt/jetty/
	sudo cp /vagrant/jetty.sh /etc/init.d/jetty
    
    # link build script
	ln -s /vagrant/deploy.sh /home/vagrant/deploy.sh
	ln -s /vagrant/context.xml /home/vagrant/context.xml
	
	ln -s /vagrant/ssh/id_vagrant_jetty_rsa /home/vagrant/.ssh/id_vagrant_jetty_rsa
	ln -s /vagrant/ssh/id_vagrant_jetty_rsa.pub /home/vagrant/.ssh/id_vagrant_jetty_rsa.pub
	eval `ssh-agent`
	ssh-add /home/vagrant/.ssh/id_vagrant_jetty_rsa &>/dev/null
	
	sudo chkconfig jetty on
	sudo service jetty start
	sudo rm jetty-distribution-9.2.1.v20140609.tar.gz
	sudo mkdir /opt/jetty/contexts
	sudo netstat -nlp | grep :80
	
	
# Install Maven 3
	cd /usr/local
	sudo wget http://ftp.fau.de/apache/maven/maven-3/3.2.1/binaries/apache-maven-3.2.1-bin.tar.gz
	sudo tar xvf apache-maven-3.2.1-bin.tar.gz
	sudo rm -rf maven
	sudo mv apache-maven-3.2.1 maven
	sudo touch /etc/profile.d/maven.sh
	sudo chown vagrant:vagrant /etc/profile.d/maven.sh 
	sudo echo "export M2_HOME=/usr/local/maven" >> /etc/profile.d/maven.sh
	sudo echo "export PATH=${M2_HOME}/bin:${PATH}" >> /etc/profile.d/maven.sh
	sudo rm apache-maven-3.2.1-bin.tar.gz
	chmod +x /etc/profile.d/maven.sh
	sud ./etc/profile.d/maven.sh
	mvn -version
	cd
	
# Setup iptables rules

	sudo iptables -F
	sudo iptables -I INPUT -j ACCEPT
	service iptables save
	sudo iptables -L -nv
	
	
# Deploy the API from master
	cd /vagrant
	sudo chmod +x deploy.sh
	sudo ./deploy.sh -e vagrant -v master -b master
