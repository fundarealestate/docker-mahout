FROM phusion/baseimage:latest

# Use baseimage's init process
CMD ["/sbin/my_init"]

MAINTAINER Firas

ENV DEBIAN_FRONTEND noninteractive
ENV JAVA_HOME       /usr/lib/jvm/java-8-oracle

## UTF-8
RUN locale-gen en_US.UTF-8
ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8

## Remove any existing JDKs
RUN apt-get --purge remove openjdk*

## Install Oracle's JDK
RUN echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections
RUN echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" > /etc/apt/sources.list.d/webupd8team-java-trusty.list
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886
RUN apt-get update && \
  apt-get install -y --no-install-recommends oracle-java8-installer bzip2 python2.7 unzip p7zip-full && \
  apt-get clean all

# Define versions and paths
ENV HADOOP_VERSION 2.6.4
ENV MAHOUT_VERSION 0.12.2
ENV PIG_VERSION 0.17.0
ENV HIVE_VERSION 1.2.2
ENV HADOOP_HOME /usr/local/hadoop-${HADOOP_VERSION}
ENV MAHOUT_HOME /usr/local/apache-mahout-distribution-${MAHOUT_VERSION}
ENV MAHOUT_LOCAL true

WORKDIR /tmp

# Download and extract Mahout
RUN wget --quiet http://www-us.apache.org/dist/mahout/${MAHOUT_VERSION}/apache-mahout-distribution-${MAHOUT_VERSION}.tar.gz && \
    tar -xzf apache-mahout-distribution-${MAHOUT_VERSION}.tar.gz && \
    mv apache-mahout-distribution-${MAHOUT_VERSION} /usr/local/apache-mahout-distribution-${MAHOUT_VERSION} && \
    ln -sf /usr/local/apache-mahout-distribution-${MAHOUT_VERSION}/bin/mahout /usr/local/bin/mahout

ENV PATH /usr/local/bin/mahout:$PATH

# Download and extract Hadoop
RUN wget --quiet https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz && \
    tar -xzf hadoop-${HADOOP_VERSION}.tar.gz && \
    mv hadoop-${HADOOP_VERSION} /usr/local/hadoop-${HADOOP_VERSION}

ENV PATH /usr/local/hadoop-${HADOOP_VERSION}/bin:$PATH
ENV PATH /usr/local/hadoop-${HADOOP_VERSION}/sbin:$PATH

# Download and install PIG
RUN wget --quiet http://www-us.apache.org/dist/pig/pig-${PIG_VERSION}/pig-${PIG_VERSION}.tar.gz && \
   tar -zxf pig-${PIG_VERSION}.tar.gz && \
   mv pig-${PIG_VERSION} /usr/local/pig-${PIG_VERSION}

ENV PATH /usr/local/pig-${PIG_VERSION}/bin:$PATH

# Download and install Hive
RUN wget --quiet http://www-us.apache.org/dist/hive/hive-${HIVE_VERSION}/apache-hive-${HIVE_VERSION}-bin.tar.gz && \
    tar -zxf apache-hive-${HIVE_VERSION}-bin.tar.gz && \
    mv apache-hive-${HIVE_VERSION}-bin /usr/local/apache-hive-${HIVE_VERSION}-bin

ENV PATH /usr/local/apache-hive-${HIVE_VERSION}-bin/bin:$PATH

# Copy the Hadoop config files from conf directory
COPY conf $HADOOP_HOME/etc/hadoop/

# Define JAVA_HOME for Hadoop
RUN echo "export JAVA_HOME=$JAVA_HOME" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh

# Formatting HDFS
RUN mkdir -p /data/dfs/data /data/dfs/name /data/dfs/namesecondary && \
    hdfs namenode -format
VOLUME /data

RUN rm -f /etc/service/sshd/down

# Enable SSH root login
RUN echo "PermitRootLogin yes" >> /etc/ssh/sshd_config

# Regenerate SSH host keys
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

# Expose Hadoop ports
# http://www.cloudera.com/content/cloudera/en/documentation/core/latest/topics/cdh_ig_ports_cdh5.html
EXPOSE 9000 50070 50010 50020 50075 50090 9021

# Setup python3.5 as default python
RUN ln -s /usr/bin/python2.7 /usr/bin/python

# cleanup temp and cache files
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache

# Call entrypoint.sh when starting the container
ADD entrypoint.sh /opt/entrypoint.sh
ENTRYPOINT ["/opt/entrypoint.sh"]

