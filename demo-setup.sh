#!/bin/bash -x
# This was ran on Lucid 64 bit machine.
# You would need a 64 bit machine to run Bigtop. However, this script can be easily ported to a different Linux based OS
WORKSPACE="workspace"
DATASET_LOC="https://raw.github.com/markgrover/apachecon-bigtop/master/median_income_by_zipcode_census_2000.zip"

# Might be an old box so let's update the repos for apt-get before we do anything else
sudo apt-get update

# Install some essential packages
sudo apt-get -y install curl vim

mkdir -p $WORKSPACE
cd $WORKSPACE

# Install java6 JDK
wget http://archive.cloudera.com/cm4/ubuntu/lucid/amd64/cm/pool/contrib/o/oracle-j2sdk1.6/oracle-j2sdk1.6_1.6.0+update31_amd64.deb
# Installing java might return a non-zero return code because of missing dependencies. This will be fixed by the next
# command to resolve broken dependecies but we should make the java installation forcefully succeed anyways
sudo dpkg -i oracle-j2sdk1.6_1.6.0+update31_amd64.deb || :
sudo apt-get -y -f install

# Install Mysql Server 5.1
sudo debconf-set-selections <<< 'mysql-server-5.1 mysql-server/root_password password root'
sudo debconf-set-selections <<< 'mysql-server-5.1 mysql-server/root_password_again password root'
sudo apt-get -y install mysql-server

wget $DATASET_LOC
sudo apt-get -y install unzip
unzip median_income_by_zipcode_census_2000.zip -d dataset
# Massage the dataset - delete first 2 header lines, get rid of any carriage returns
sed -i -e 1d -e 2d -e 's/\r//g' -e 's/,\"/,/g' -e 's/\",/,/g' -e 's/, /,/g'  dataset/DEC_00_SF3_P077_with_ann.csv

# Create dataset in MySQL
mysql -uroot -proot -e "
create schema demo;
use demo;
create table zipcode_incomes(
  id varchar(255),
  zip varchar(255),
  description1 varchar(255),
  description2 varchar(255),
  income int(11));
"
mysql -uroot -proot -e "load data local infile 'dataset/DEC_00_SF3_P077_with_ann.csv' into table demo.zipcode_incomes fields terminated by ',' lines terminated by '\n'"

# Plan B: in case of internet connectivity, it will be nice to have all the debs and dependencies so
# we can just install all components from there
mkdir debs
cd debs
# This was done on lucid which doesn't have the recently introduced apt-get download functionality
# so we have to do some hackery to download all the debs required
PKGS="bigtop-jsvc bigtop-tomcat bigtop-utils hadoop hadoop-client hadoop-conf-pseudo hadoop-hdfs hadoop-hdfs-datanode \
hadoop-hdfs-namenode hadoop-hdfs-secondarynamenode hadoop-mapreduce hadoop-mapreduce-historyserver \
hadoop-yarn hadoop-yarn-nodemanager hadoop-yarn-resourcemanager hive hive-jdbc zookeeper"
OR_SEPARATED=${PKGS// /_\\|}
URLS=`curl http://bigtop.s3.amazonaws.com/releases/0.6.0/ubuntu/lucid/x86_64/dists/bigtop/contrib/binary-amd64/Packages | sed -ne '/^Filename:/s#^Filename: #'"http://bigtop.s3.amazonaws.com/releases/0.6.0/ubuntu/lucid/x86_64/"'#p' | grep $OR_SEPARATED`
wget $URLS
cd ..

