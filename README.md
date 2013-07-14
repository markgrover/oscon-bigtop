oscon-bigtop
============

Resources for the demo presented at Bigtop presentation at OSCON 2013

Introduction
------------
This repository contains data and code for use by a beginner's introduction to Apache Bigtop. All instructions have been inspired from the instructions on the [Bigtop wiki page for 0.6.0](https://cwiki.apache.org/confluence/display/BIGTOP/How+to+install+Hadoop+distribution+from+Bigtop+0.6.0)

File list and description
-------------------------
* <b>README.md:</b> This file, with instructions for your use
* <b>demo-setup.sh:</b> A script I used to provision a single node for using in my demo. This script installs some essential tools and software, grabs a well known publicly available dataset and inserts it into a relational DB. Note that this script was run on Ubuntu Lucid 64 bit machine. It should work on other Ubuntu/Debian variants as well. It can be easily ported for use on RPM based systems. I haven't gotten a chance to do so but if you decide to do so, please send me a pull request, thanks! Note that Ubuntu doesn't come with JDK6 by default so this script also installs Oracle JDK6. By the time this script is done, your machine is ready for installing Bigtop as per the instructions below.
* <b>median_income_by_zipcode_census_2000.zip:</b> A household income dataset from 2000 United States Census for use in the demo.

Instructions
------------
Inspired from the [Bigtop wiki page](https://cwiki.apache.org/confluence/display/BIGTOP/How+to+install+Hadoop+distribution+from+Bigtop+0.6.0)
* Add Bigtop key so you can use the Bigtop artifacts with apt-get
<pre>
wget -O- http://archive.apache.org/dist/bigtop/bigtop-0.6.0/repos/GPG-KEY-bigtop | sudo apt-key add -
</pre>
* Add Bigtop list, so apt-get knows where to find the Bigtop artifacts
<pre>
sudo wget -O /etc/apt/sources.list.d/bigtop-0.6.0.list http://archive.apache.org/dist/bigtop/bigtop-0.6.0/repos/`lsb_release --codename --short`/bigtop.list
</pre>
* Update apt-get so it sees our newly added Bigtop repository
* <pre>
sudo apt-get update
</pre>
* Install our pseduo-distributed hadoop package from Apache Bigtop
<pre>
sudo apt-get install hadoop-conf-pseudo
</pre>
* Initialize the name (needs to be done only once). Don't do it again, it will format (i.e wipe off) the data in your cluster (i.e. data on HDFS).
sudo service hadoop-hdfs-namenode init
* Start the namenode and datanode
<pre>
sudo service hadoop-hdfs-namenode start
sudo service hadoop-hdfs-datanode start
</pre>
* Initialize HDFS. This creates a bunch of directories on HDFS that are required for YARN to run
<pre>
./init-hdfs.sh
</pre>
* Restart YARN daemons. Yarn needs the directories created by the previous step to work properly. Since we just created those directories, let's restart YARN daemons.
<pre>
sudo service hadoop-yarn-resourcemanager restart
sudo service hadoop-yarn-nodemanager restart
</pre>
* Time to run our first MapReduce Job. This is run using MapReduce v2, running on top of YARN.
<pre>
hadoop jar /usr/lib/hadoop-mapreduce/hadoop-mapreduce-examples*.jar pi 10 1000
</pre>
* If you want to install more artifacts, all you do is run a simple apt-get command
<pre>
sudo apt-get install hive sqoop
</pre>
* In order to use sqoop with MySQL, you need to download the MySQL connector and drop it in Sqoop's lib directory. It doesn't get shipped with Sqoop due to licensing reasons
<pre>
curl -L 'http://www.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.24.tar.gz/from/http://mysql.he.net/' | tar xz
sudo cp mysql-connector-java-5.1.24/mysql-connector-java-5.1.24-bin.jar /usr/lib/sqoop/lib/
</pre>
* Now we can run the command to import our table containing census data from MySQL to Hive, using Sqoop
<pre>
sqoop import --connect jdbc:mysql://localhost/demo --table zipcode_incomes --username root -P -m 1 --create-hive-table --hive-import --hive-overwrite
</pre>
