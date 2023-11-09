#!/bin/bash
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

image=${1}
if [[ $image == "" ]];then
    image="nginx"
fi

check_root=0

docker_compose_file=$(docker inspect ${image} | grep "com.docker.compose.project.config_files" | cut -d ':' -f 2 | sed "s/\"//g" | sed "s/,//")

if [[ $docker_compose_file != "" ]];then
    echo -e "\ncheck docker compose file: ${CYAN}${docker_compose_file}${NC}"
    cat $docker_compose_file
    exit 0
fi

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

docker_service=$(echo $docker_inspect_file | jq ".[].Config.Labels.\"com.docker.compose.service\"" -r)
docker_name=$(echo $docker_inspect_file | jq .[].Name -r | sed 's|/||')
docker_hostname=$(echo $docker_inspect_file | jq .[].Config.Hostname -r)
docker_image=$(echo $docker_inspect_file | jq ".[].Config.Image" -r)

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
    arr_cmd+=("            $line\n")
done

# ENTRYPOINT
arr_entry=()
e_points=$(echo $docker_inspect_file | jq .[].Config.Entrypoint | sed "s/\[//" | sed "s/\]//" | sed "s/\"//g")
for line in $e_points; do
    arr_entry+=("            - $line")
done

# PORTS
arr_ports=()

(echo $docker_inspect_file | jq '.[].HostConfig.PortBindings' | jq "keys | .[]" -r > /dev/null) || status=2
parent_ports=$(echo $docker_inspect_file | jq '.[].HostConfig.PortBindings' | jq "keys | .[]" -r)
ports_length=$(echo $parent_ports | wc -l)
if [[ $status != 2 ]];then
    for parent_port in $parent_ports; do
        for pport in $parent_port; do
            host_ip=$(echo $docker_inspect_file | jq ".[].HostConfig.PortBindings" | jq ".[\"$pport\"][] | .HostIp" -r) 
            if [[ $host_ip == "" ]]; then
                host_ip="0.0.0.0"
            fi
            host_port=$(echo $docker_inspect_file | jq ".[].HostConfig.PortBindings" | jq ".[\"$pport\"][] | .HostPort" -r)
            arr_ports+=("            - ${host_ip}:${host_port}:${parent_port}\n")
        done
    done
else
    arr_ports=('""')
fi

# RESTART POLICY
restart_policy=$(echo $docker_inspect_file | jq ".[].HostConfig.RestartPolicy.Name" -r)
[[ $restart_policy == "" ]] && restart_policy="\"nos\""

# VOLUMES
i=0
volume_length=$(echo $docker_inspect_file | jq '.[].Mounts[].Type' | wc -l)
arr_volumes=()
while [[ $i -lt $volume_length ]]; do
    volume_src=$(echo $docker_inspect_file | jq ".[].Mounts[${i}].Source" -r)
    volume_dst=$(echo $docker_inspect_file | jq ".[].Mounts[${i}].Destination" -r)
    volume_dst_mode=$(echo $docker_inspect_file | jq ".[].Mounts[${i}].Mode" -r)
    arr_volumes+=("            - ${volume_src}:${volume_dst}:${volume_dst_mode}\n")
    let i=i+1
done

function composer(){
    echo -e """
version: '3'
services:
    ${docker_service}:
        image: ${docker_image}
        container_name: "$docker_name"
        hostname: "$docker_hostname"
        restart: ${restart_policy}
        command: >\n ${arr_cmd[@]}
        entrypoint:\n ${arr_entry[@]}
        ports:\n ${arr_ports[@]}
        environment:\n ${arr_env[@]}
        volumes:\n ${arr_volumes[@]}
    """  > temp-compose.yaml
}
composer 
