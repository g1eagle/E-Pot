echo "Lets setup the PI"
echo "Update the pi? [y/n]"
read updatepi

if [ "$updatepi" == "y" ]; then
	[ -e /usr/lib/apt/methods/https ] || {
  	sudo apt-get update
  	sudo apt-get install apt-transport-https
	}
fi

echo "Install python-pip and docker-compose? [y/n]"
read installpip
if [ "$installpip" == "y" ]; then
  sudo apt-get install -y python-pip
  sudo pip install docker-compose
fi


echo "Setup the enviroment"
#/usr/bin/env bash
DIR=$(cd $(dirname "$0"); pwd)
KIPPO_UID=499:499
DIONAEA_UID=nobody:nogroup
YML=https://raw.githubusercontent.com/g1eagle/E-Pot/master/rpi-compose.yml

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



echo "Grab the PI version of Mysql"
docker pull hypriot/rpi-mysql

echo "Enter Root User name for Mysql"
read root

echo "Enter Root Password for Mysql"
read mysqlpw

echo "Setting up mysql"
docker run --name mysql -v /var/mysql:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=$mysqlpw -d mysql

sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}:3306' mysql | xargs wget --retry-connrefused --tries=5 -q --wait=5 --spider

docker run -d --link mysql:mysql -e MYSQL_USERNAME=$root --name phpmyadmin -p 3240:80 g1eagle/docker_phpmyadmin

sudo curl -q https://raw.githubusercontent.com/g1eagle/E-Pot/master/start.sh > /etc/start.sh

echo "Setup rest of containers"
sudo docker-compose up -d

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
sudo sed -i "s:-dir-:$DIR:" /etc/start.sh

echo "$DIR"

sudo docker start kippo
sudo docker start glastopf


