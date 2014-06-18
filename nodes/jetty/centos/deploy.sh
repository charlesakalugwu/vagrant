#!/bin/bash

usage()
{
cat << EOF
usage: $0 options

OPTIONS:
-h      Show this message
-e      enviromnment production|staging  - default staging
-n      notify new relic of new build
-b      mandatory - define branch to deploy (must be available in both ydData, ydRest, ydFlow)
-v      mandatory - specify the version to deploy (affects the url of all the api calls)
EOF
}

ENV=vagrant
NOTIFY=0
BRANCH=master
VERSION=test
BRANCH_FLAG=false
VERSION_FLAG=false
while getopts ":he:nb:v:" OPTION
do
    case $OPTION in
        h)
            usage
            exit 1
            ;;
        e)
            ENV=$OPTARG
            ;;
        n)
            NOTIFY=1
            ;;
        b)
            BRANCH=$OPTARG
            BRANCH_FLAG=true
            ;;
        v)
            VERSION=$OPTARG
            VERSION_FLAG=true
            ;;
        :)
            echo "Missing option argument for -$OPTARG" >&2; 
            usage
            exit 1
            ;;
        ?)
            usage
            exit
            ;;

	esac
done

# Check correctness of the arguments
if [ "$ENV" != "production" -a "$ENV" != "staging" -a "$ENV" != "vagrant" ] ;then
    echo "The value '$ENV' for the argument e (Environment) is not valid. It must be 'production' or 'staging'"
    usage
    exit 1
fi

if ! $BRANCH_FLAG ;then
    echo "The argument -b is mandatory. Please provide a branch"
    usage
    exit 1
fi

if ! $VERSION_FLAG ;then
    echo "The argument -v is mandatory. Please provide a version"
    usage
    exit 1
fi

echo "Deploying $ENV API from branch $BRANCH into version $VERSION"

# stopping all workers
# forever stopall

# stopping jetty
sudo service jetty stop

# updating ydData and ydRest
if [ ! -d ydData ];then
    git clone git@github.com:yourdelivery/ydData.git ydData
fi
if [ ! -d ydRest ];then
    git clone git@github.com:yourdelivery/ydRest.git ydRest
fi
if [ ! -d ydFlow ];then
    git clone git@github.com:yourdelivery/ydFlow.git ydFlow
fi

#initialize repositories
cd ydData
git checkout master
git reset --hard HEAD
git pull
git checkout $BRANCH
git pull origin $BRANCH
mvn clean
mvn install -DskipTests

cd ..

cd ydFlow
git checkout master
git reset --hard HEAD
git pull 
git checkout $BRANCH
mvn clean
mvn install -DskipTests

cd ..

cd ydRest
git checkout master
git reset --hard HEAD
git pull 
git checkout $BRANCH
git pull origin $BRANCH
mvn clean
mvn validate

if [ "$ENV" == "production" ];then
    sudo cat /vagrant/context.xml | sed -e "s/#VERSION#/$VERSION/g" | sed -e "s/#ROOT_PATH#/api/g" | sed -e "s/#CONTEXT_NAME#/production/g" | sed -e "s/#ENVIROMENT#/live/g" > /opt/jetty/contexts/production-$VERSION.xml
    sudo mvn install -DskipTests -Denv=live -Djettydir=/opt/jetty/webapps -Dcontainer=production-$VERSION
fi

if [ "$ENV" == "staging" ];then
    sudo cat /vagrant/context.xml | sed -e "s/#VERSION#/$VERSION/g" | sed -e "s/#ROOT_PATH#/stage/g" | sed -e "s/#CONTEXT_NAME#/staging/g" | sed -e "s/#ENVIROMENT#/staging/g" > /opt/jetty/contexts/staging-$VERSION.xml
    sudo mvn install -DskipTests -Denv=staging -Djettydir=/opt/jetty/webapps -Dcontainer=staging-$VERSION
fi

if [ "$ENV" == "vagrant" ];then
    sudo cat /vagrant/context.xml | sed -e "s/#VERSION#/$VERSION/g" | sed -e "s/#ROOT_PATH#/rest/g" | sed -e "s/#CONTEXT_NAME#/vagrant/g" | sed -e "s/#ENVIROMENT#/vagrant/g" > /opt/jetty/contexts/vagrant-$VERSION.xml
    sudo mvn install -DskipTests -Denv=staging -Djettydir=/opt/jetty/webapps -Dcontainer=vagrant-$VERSION
fi

sudo service jetty start
