#install docker (skip if you have docker 1.3+ already)
[ -e /usr/lib/apt/methods/https ] || {
  sudo apt-get update
  sudo apt-get install apt-transport-https
}

sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys \
    36A1D7869245C8950F966E92D8576A8BA88D21E9

sudo sh -c "echo deb https://get.docker.com/ubuntu docker main > \
    /etc/apt/sources.list.d/docker.list"

sudo apt-get update
sudo apt-get -y install lxc-docker

#install docker-compose
sudo apt-get install -y python-pip
sudo pip install docker-compose

#/usr/bin/env bash
DIR=$(cd $(dirname "$0"); pwd)
KIPPO_UID=499:499
DIONAEA_UID=nobody:nogroup
YML=https://raw.githubusercontent.com/g1eagle/E-Pot/master/docker-compose2.yml

#donwload/update yml
curl -q $YML > docker-compose.yml

# Move SSH server from Port 22 to Port 66534
echo "Moving SSH server to port 65534"
sudo sed -i 's:Port 22:Port 65534:g' /etc/ssh/sshd_config
sudo service ssh reload

# Directory setup
echo "Putting files in $DIR/var"
mkdir -p $DIR/var/kippo $DIR/var/dionaea $DIR/var/glastopf

#Dionaea's directories
mkdir -p $DIR/var/dionaea/wwwroot
mkdir -p $DIR/var/dionaea/binaries
mkdir -p $DIR/var/dionaea/log
mkdir -p $DIR/var/dionaea/bistreams

sudo chown -R $KIPPO_UID $DIR/var/kippo 
sudo chown -R $DIONAEA_UID $DIR/var/dionaea
sudo chown -R $DIONAEA_UID $DIR/var/glastopf

sudo docker-compose up -d
