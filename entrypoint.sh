#! /bin/bash

set -e

# Start SSH server (needed by Hadoop)
service ssh start
# Setup SSH keys to prevent Hadoop from asking for password
cat /dev/zero | ssh-keygen -q -N ""
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 0600 ~/.ssh/authorized_keys
ssh-keyscan -H localhost >> ~/.ssh/known_hosts
ssh-keyscan -H 0.0.0.0 >> ~/.ssh/known_hosts
# Start HDFS and Yarn
start-all.sh && mr-jobhistory-daemon.sh start historyserver

exec "$@"
