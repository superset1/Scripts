#!/bin/bash

echo "Use local system volume mounts to start the Runner container - 1"
echo "Use Docker volumes to start the Runner container - 2"
read -n1 answer
echo

# Install Docker if not exist
if ! [[ -f /usr/bin/docker ]]; then
      apt-get remove docker docker-engine docker.io containerd runc
      apt-get update
      apt-get install -y ca-certificates curl gnupg lsb-release
      curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
            $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
      apt-get update
      apt-get install -y docker-ce docker-ce-cli containerd.io
      # Or instead you can use the following commands
      # curl -fsSL https://get.docker.com -o get-docker.sh
      # DRY_RUN=1 sh ./get-docker.sh
fi

if [[ $answer == 1 ]]; then
      # Start the GitLab Runner container
      docker run -d --name gitlab-runner --restart always \
        -v /srv/gitlab-runner/config:/etc/gitlab-runner \
        -v /var/run/docker.sock:/var/run/docker.sock \
        gitlab/gitlab-runner:latest
      # Register for local system volume mounts  
      docker run --rm -it -v /srv/gitlab-runner/config:/etc/gitlab-runner gitlab/gitlab-runner register  
 elif [[ $answer == 2 ]]; then
      # Create the Docker volume
      docker volume create gitlab-runner-config
      # Start the GitLab Runner container using the volume we just created
      docker run -d --name gitlab-runner --restart always \
         -v /var/run/docker.sock:/var/run/docker.sock \
         -v gitlab-runner-config:/etc/gitlab-runner \
         gitlab/gitlab-runner:latest
      # Register for Docker volume mounts
      docker run --rm -it -v gitlab-runner-config:/etc/gitlab-runner gitlab/gitlab-runner:latest register   
 else 
      echo -e "\nNothing to do"
fi