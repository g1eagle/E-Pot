#!/bin/bash
DIR='-dir-'
sleep 10 
RUNNING=$(sudo docker inspect --format '{{.State.Running}}' mysql)
while [ "$RUNNING"  == false ]; do
    if [ "$RUNNING" == false ]
    then
       # do something wise
        sudo docker start mysql
        
    fi
    sleep 20s
    RUNNING=$(sudo docker inspect --format '{{.Sate.Running}}' mysql)
done

RUNNING=$(sudo docker inspect --format '{{.State.Running}}' dionaea)
while [ "$RUNNING"  == false ]; do
    if [ "$RUNNING" == false ]
    then
       # do something wise
        sudo docker start dionaea
        echo "running dionaea"
    fi
    sleep 20s
    RUNNING=$(sudo docker inspect --format '{{.State.Running}}' dionaea)
done


sleep 30s
MYSQLIP=$(sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}' mysql)
echo "$MYSQLIP"
sudo cp $DIR/var/glastopf/glastopf.cfg2 $DIR/var/glastopf/glastopf.cfg
sudo cp $DIR//var/kippo/kippo.cfg2 $DIR/var/kippo/kippo.cfg
sudo sed -i "s/-localhost-/$MYSQLIP/" $DIR/var/glastopf/glastopf.cfg
sudo sed -i "s/-localhost-/$MYSQLIP/" $DIR/var/kippo/kippo.cfg


RUNNING=$(sudo docker inspect --format '{{.State.Running}}' glastopf)
while [ "$RUNNING"  == false ]; do
    if [ "$RUNNING" == false ]
    then
       # do something wise
        sudo docker start glastopf
        echo "running glastopf"
    fi
    sleep 20s
    RUNNING=$(sudo docker inspect --format '{{.State.Running}}' glastopf)
done


RUNNING=$(sudo docker inspect --format '{{.State.Running}}' kippo)
while [ "$RUNNING"  == false ]; do
    if [ "$RUNNING" == false ]
    then
       # do something wise
        sudo docker start kippo
        echo "running kippo"
    fi
    sleep 20s
    RUNNING=$(sudo docker inspect --format '{{.State.Running}}' kippo)
done
