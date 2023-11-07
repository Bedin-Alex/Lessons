#!/bin/bash
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

image=${1}
if [[ $image == "" ]];then
    image="nginx"
fi

check_root=0

if [[ ! (-f /usr/bin/jq) ]];then
    status="Error"
fi

if [[ $(echo ${status} | grep -oE "Error") == "Error" ]]; then
    echo "Not Installed"
    if [[ "$EUID" -eq 1 ]];then
        apt install jq -y
    else
        echo -e "${RED}You are not root user and JQ is not installed${NC}"
    fi
fi

docker_inspect_file=$(docker inspect ${image})

docker_compose_file=$(echo $docker_inspect_file | jq .[0].Config.Labels1 | grep "project.config_files" | cut -d ':' -f 2 | sed "s/ //g" | sed "s/\"//g" | sed "s/,//")

if [[ $docker_compose_file != "" ]]; then
    echo -e "I found compose file here: ${CYAN}${docker_compose_file}${NC}"
    exit 0
fi

docker_name=$(echo $docker_inspect_file | jq .[].Name -r)
docker_hostname=$(echo $docker_inspect_file | jq .[].Config.Hostname -r)

# ENV
arr_env=()
line_envs=$(echo $docker_inspect_file | jq .[].Config.Env | sed "s/\[//" | sed "s/\]//" | sed "s/ //g" | sed "s/\"//g" | sed "s/,//")
for line in $line_envs; do
    arr_env+=("            - $line\n")
done

# CMD
arr_cmd=()
line_cmd=$(echo $docker_inspect_file | jq .[].Config.Cmd | sed "s/\[//" | sed "s/\]//" | sed "s/^  //g" | sed "s/\"//g" | sed "s/,//" | sed "s/;//g")
for line in $line_cmd; do
    arr_cmd+=("            - $line\n")
done

# ENTRYPOINT
arr_entry=()
e_points=$(echo $docker_inspect_file | jq .[].Config.Entrypoint | sed "s/\[//" | sed "s/\]//" | sed "s/\"//g")
for line in $e_points; do
    arr_entry+=("            - $line")
done

# PORTS
ports_array=()

(echo $docker_inspect_file | jq '.[].HostConfig.PortBindings' | jq "keys | .[]" -r) || status=2

if [[ $status != 2 ]];then
    parent_port=$(echo $docker_inspect_file | jq '.[].HostConfig.PortBindings' | jq "keys | .[]" -r)
    for pport in $parent_port; do
        host_ip=$(echo $docker_inspect_file | jq ".[].HostConfig.PortBindings" | jq ".[\"$pport\"][] | .HostIp" -r) 
        if [[ $host_ip == "" ]]; then
            host_ip="0.0.0.0"
        fi
        host_port=$(echo $docker_inspect_file | jq ".[].HostConfig.PortBindings" | jq ".[\"$pport\"][] | .HostPort" -r)
        ports_array+=("            - ${host_ip}:${host_port}:${parent_port}\n")
    done
else
    ports_array=('""')
fi

function composer(){
    echo -e """
version: '3'
services:
    test:
        container_name: "$docker_name"
        hostname: "$docker_hostname"
        command:\n ${arr_cmd[@]}
        entrypoint:\n ${arr_entry[@]}
        ports:\n ${ports_array}
        environment:\n ${arr_env[@]}

    """ > temp-compose.yaml
}
composer 
