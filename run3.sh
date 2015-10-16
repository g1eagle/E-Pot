#install docker (skip if you have docker 1.3+ already)
[ -e /usr/lib/apt/methods/https ] || {
  sudo apt-get update
  sudo apt-get install apt-transport-https
}

echo "Install docker? [y/n]"
read docker

if [ "$docker" == "y" ]; then
	sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9

	sudo sh -c "echo deb https://get.docker.com/ubuntu docker main > /etc/apt/sources.list.d/docker.list"

	sudo apt-get update
	sudo apt-get -y install lxc-docker
fi

#install docker-compose
sudo apt-get install -y python-pip
sudo pip install docker-compose

echo "Enter Root User name"
read root

echo "Enter Root Password for mysql"
read mysqlpw


#/usr/bin/env bash
DIR=$(cd $(dirname "$0"); pwd)
KIPPO_UID=499:499
DIONAEA_UID=nobody:nogroup
YML=https://raw.githubusercontent.com/g1eagle/E-Pot/master/docker-compose3.yml

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

mkdir -p $DIR/var/mysql

sudo chown -R $KIPPO_UID $DIR/var/kippo 
sudo chown -R $DIONAEA_UID $DIR/var/dionaea
sudo chown -R $DIONAEA_UID $DIR/var/glastopf
sudo chown -R $DIONAEA_UID $DIR/var/mysql

docker run --name mysql -v /var/mysql:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=$mysqlpw -d mysql

echo "docker run --restart=always --name mysql -v /var/mysql:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=$mysqlpw -d mysql"
echo "docker run -d --link mysql:mysql -e MYSQL_USERNAME=$root --name phpmyadmin -p 3240:80 g1eagle/docker_phpmyadmin"


sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}:3306' mysql | xargs wget --retry-connrefused --tries=5 -q --wait=5 --spider

sudo docker-compose up -d

docker run -d --link mysql:mysql -e MYSQL_USERNAME=$root --name phpmyadmin -p 3240:80 g1eagle/docker_phpmyadmin


sudo curl -q https://raw.githubusercontent.com/g1eagle/E-Pot/master/start.sh > /etc/start.sh


echo "Enter Glastopf User name"
read glastopfuser

echo "Enter Glastopf Password for mysql"
read glastopfpass

echo "Enter Kippo User name"
read kippouser

echo "Enter Kippo Password for mysql"
read kippopass

sudo docker stop kippo
sudo docker stop glastopf

sudo curl -q https://raw.githubusercontent.com/g1eagle/E-Pot/master/Docker%20Setup/kippo.cfg2 > $DIR/var/kippo/kippo.cfg2
sudo curl -q https://github.com/g1eagle/E-Pot/blob/master/Docker%20Setup/glastopf.cfg2 > $DIR/var/glastopf/glastopf.cfg2

sudo curl -q https://raw.githubusercontent.com/g1eagle/E-Pot/master/loadSQL.sql > $DIR/loadSQL.sql
sudo sed -i "s/-glastopfuser-/$glastopfuser/" $DIR/var/glastopf/glastopf.cfg2
sudo sed -i "s/-glastopfpass-/$glastopfpass/" $DIR/var/glastopf/glastopf.cfg2

sudo sed -i "s/-kippouser-/$kippouser/" $DIR/var/kippo/kippo.cfg2
sudo sed -i "s/-kippopass-/$kippopass/" $DIR/var/kippo/kippo.cfg2


sudo sed -i "s/-glastopfuser-/$glastopfuser/" $DIR/loadSQL.sql
sudo sed -i "s/-glastopfpass-/$glastopfpass/" $DIR/loadSQL.sql
sudo sed -i "s/-kippouser-/$kippouser/" $DIR/loadSQL.sql
sudo sed -i "s/-kippopass-/$kippopass/" $DIR/loadSQL.sql
echo "load start"
sudo sed -i "s:dir:$DIR:" /etc/start.sh

echo "$DIR"

sudo docker start kippo
sudo docker start glastopf

echo '################################################'
echo '# Load contents of loadSQL.sql into phpmyadmin #'
echo '################################################'

echo '################################################'
echo '# Then configure sys link in Kippo container   #'
echo '################################################'
