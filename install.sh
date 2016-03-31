#!/bin/sh

# Install docker and GIT
apt-get update
apt-get install apt-transport-https ca-certificates
apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" > /etc/apt/sources.list.d/docker.list
apt-get update
apt-get install linux-image-extra-$(uname -r) apparmor docker-engine git -y

# Get docker container for postgres
docker pull postgres

# Run postgres docker container
docker run --name railsPostgres --restart=always -e POSTGRES_PASSWORD=${1} -d postgres

# Wait for postgres to start up
sleep 20

# Create an application in postgres
dosql="CREATE ROLE ${2} WITH LOGIN CREATEDB PASSWORD '${3}'"
conn="postgresql://postgres:${1}@railsPostgres:5432"
docker run -i --link railsPostgres:postgres --rm postgres sh -c "exec psql $conn -c \"$dosql\""
