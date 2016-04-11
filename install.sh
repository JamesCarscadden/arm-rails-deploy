#!/bin/sh
set -e

# attempt to avoid problems with dpkg being locked by other processes which are
# presumably running as part of the ARM provisioning
sleep 2m

# add our user and group first to make sure their IDs get assigned consistently,
# regardless of whatever dependencies get added
groupadd -r railsapp && useradd -r -g railsapp railsapp

# Install docker and GIT
apt-get update
apt-get install -y apt-transport-https ca-certificates
apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" > /etc/apt/sources.list.d/docker.list
apt-get update
apt-get install -y linux-image-extra-$(uname -r) apparmor docker-engine git

usermod -a -G docker ${1}

# Get docker container for postgres
docker pull postgres

# Run postgres docker container
docker run --name railsPostgres --restart=always -e POSTGRES_PASSWORD=${2} -d postgres

# Wait for postgres to start up
sleep 20

# Create an application in postgres
dosql="CREATE ROLE ${3} WITH LOGIN CREATEDB PASSWORD '${4}'"
conn="postgresql://postgres:${2}@railsPostgres:5432"
docker run -i --link railsPostgres:postgres --rm postgres sh -c "exec psql $conn -c \"$dosql\""
