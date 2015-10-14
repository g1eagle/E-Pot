#!/bin/bash
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

MYSQLIP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' mysql)
cp /home/Student/var/glastopf/glastopf.cfg2 /home/Student/var/glastopf/glastopf.cfg
sed -i "s/-localgost-/$MYSQLIP/" /home/Student/var/glastopf.cfg

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