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

Demo VM setup
-------------
Let's prepare a VM for your setup. You can use any of OS for your VM. The setup script <b>dmeo-setup.sh</b> was run and has only been tested on Lucid. Also, I use [vagrant](http://www.vagrantup.com/) for all my VM needs. Vagrant builds on top of Virtualbox but you are welcome to use any VM Hypervisor software of your choice. All you need is a vanilla Linux install at the end of the day:-)
Log in to the VM and run the following commands:

<pre>
<code>
wget https://raw.github.com/markgrover/oscon-bigtop/master/demo-setup.sh
./demo-setup.sh
</code>
</pre>

This setup may take a while, please be patient!

Instructions
------------
Inspired from the [Bigtop wiki page](https://cwiki.apache.org/confluence/display/BIGTOP/How+to+install+Hadoop+distribution+from+Bigtop+0.6.0)
* Add Bigtop key so you can use the Bigtop artifacts with apt-get

<pre>
<code>
wget -O- http://archive.apache.org/dist/bigtop/bigtop-0.6.0/repos/GPG-KEY-bigtop | sudo apt-key add -
</code>
</pre>

* Add Bigtop list, so apt-get knows where to find the Bigtop artifacts

<pre>
<code>
sudo wget -O /etc/apt/sources.list.d/bigtop-0.6.0.list http://archive.apache.org/dist/bigtop/bigtop-0.6.0/repos/`lsb_release --codename --short`/bigtop.list
</code>
</pre>

* Update apt-get so it sees our newly added Bigtop repository

<pre>
<code>
sudo apt-get update
</code>
</pre>

* Install our pseduo-distributed hadoop package from Apache Bigtop

<pre>
<code>
sudo apt-get install hadoop-conf-pseudo
</code>
</pre>

* Initialize the name (needs to be done only once). Don't do it again, it will format (i.e wipe off) the data in your cluster (i.e. data on HDFS).

<pre>
<code>
sudo service hadoop-hdfs-namenode init
</code>
</pre>

* Start the namenode and datanode

<pre>
<code>
sudo service hadoop-hdfs-namenode start
sudo service hadoop-hdfs-datanode start
</code>
</pre>

* Initialize HDFS. This creates a bunch of directories on HDFS that are required for YARN to run

<pre>
<code>
sudo /usr/lib/hadoop/libexec/init-hdfs.sh -u $USER
</pre>
</code>

* Restart YARN daemons. Yarn needs the directories created by the previous step to work properly. Since we just created those directories, let's restart YARN daemons.

<pre>
<code>
sudo service hadoop-yarn-resourcemanager restart
sudo service hadoop-yarn-nodemanager restart
</pre>
</code>

* Time to run our first MapReduce Job. This is run using MapReduce v2, running on top of YARN.

<pre>
<code>
hadoop jar /usr/lib/hadoop-mapreduce/hadoop-mapreduce-examples*.jar pi 10 1000
</code>
</pre>

* If you want to install more artifacts, all you do is run a simple apt-get command

<pre>
<code>
sudo apt-get install hive
</code>
</pre>

* There is a [bug in Bigtop](https://issues.apache.org/jira/browse/BIGTOP-987) because of which we have to correct the permission of one of the HDFS directories before we run hive. Let's do that first

<pre>
<code>
sudo -u hdfs hadoop fs -chmod -R 1777 /tmp
</code>
</pre>

* Let's create a table in Hive

<pre>
<code>
CREATE TABLE zipcode_incomes(id STRING, zip STRING, description1 STRING, description2 STRING, income INT)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
</code>
</pre>


* Load the data in Hive

<pre>
<code>
cd ~
LOAD DATA LOCAL INPATH 'workspace/dataset/DEC_00_SF3_P077_with_ann.csv' OVERWRITE INTO TABLE zipcode_incomes;
</code>
</pre>

* Run Hive queries!

To clean up (only if necessary)
-------------------------------

<pre>
<code>
sudo rm -rf /var/lib/hadoop-hdfs/cache/*
sudo service hadoop-hdfs-datanode stop
sudo service hadoop-hdfs-namenode stop
sudo service hadoop-hdfs-namenode init
</code>
</pre>
