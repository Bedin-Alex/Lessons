#!/bin/bash
menu(){
echo "1 - Start"
echo "2 - Stop"
echo "3 - First Start"
read chose
if [[ $chose == "1" ]];
then
 start_docker
fi

if [[ $chose == "3" ]];
then
 first_start_docker
fi

if [[ $chose == "2" ]];
then
 stop_docker
fi
}

first_start_docker(){
 docker-compose up -d
 sleep 20
 docker exec -it mysql /dir/script.sh
}

stop_docker(){
 docker-compose down
}

start_docker(){
 docker-compose up -d
}

menu
