#!/bin/sh
# Create SSH Tunnel and check to ensure tunnel is successfully created, if errors, try again up to 5 times
	echo "Opening SSH tunnel to ACS..."
		n=0
		until [ $n -ge 5 ]
		do
			ssh -fNL $local_port:localhost:$remote_port -p 2200 azureuser@$(cat fqdn) -o StrictHostKeyChecking=no -o ServerAliveInterval=240 &>/dev/null && echo "ACS SSH Tunnel successfully opened..." && break
			n=$((n+1)) &>/dev/null && echo "SSH tunnel is not ready. Retrying in 5 seconds..."
			sleep 5
		done 

# Check for ACS Cluster Node availability, if errors, try again up to 5 times - only necessary if ACS Cluster was recently deployed
	n=0
	until [ $n -ge 5 ]
	do
		docker info | grep 'Nodes: [1-9]' &>/dev/null && echo "$Orchestrator cluster is ready..." && break ## if docker Swarm
		n=$((n+1)) &>/dev/null && echo "$Orchestrator cluster is not ready. Retrying in 45 seconds..."
		sleep 45
	done 

# Docker check if first arg is `-f` or `--some-option`
	# if [ "${1#-}" != "$1" ]; then
	if [ "${1:0:1}" = '-' ]; then
		set -- docker "$@"
	fi

# If our command is a valid Docker subcommand, invoke it through Docker instead - (this allows for "docker run docker ps", etc)
	if docker help "$1" &>/dev/null; then
		set -- docker "$@"
	fi
# Out to end user and execute docker command
	echo "Reminder: Your web applications can be viewed here: $(cat agents)"
	echo "Executing supplied $Orchestrator command: '$@'"
	eval "$@" && echo "'$@' completed" 

	# && echo "Supplied command successfully completed..." [ STOPPED HERE; FIGURE OUT HOW TO ECHO SUCCESS TO END USER]

	## if [ "$Orchestrator" -eq "Swarm" ] then; 
		#docker info | grep 'Nodes: [1-9]' &>/dev/null && echo "$Orchestrator cluster is ready..." && break
	 # fi

	## if [ "$Orchestrator" -eq "Kubernetes" ] then; 
		#docker info | grep 'Nodes: [1-9]' &>/dev/null && echo "$Orchestrator cluster is ready..." && break
	 # fi

	## if [ "$Orchestrator" -eq "dcos" ] then; 
		#docker info | grep 'Nodes: [1-9]' &>/dev/null && echo "$Orchestrator cluster is ready..." && break
	 # fi