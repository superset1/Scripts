#!/bin/bash

SERVER=git.roadtodevops.online
CERTIFICATE=/etc/gitlab-runner/certs/${SERVER}.crt
PROTOCOL="https"
PORT=443
SSL=$1
REGISTRATION_TOKEN=$2
EXECUTOR=$3
DOCKER_IMAGE=$4

if ! [[ -f /usr/local/bin/gitlab-runner ]]; then
        # Sudo without password
        sed -i '/gitlab-runner/d' /etc/sudoers
        echo "gitlab-runner ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
        echo

        # Install Git, Curl
        apt install -y git curl

        # Download the binary for your system
        curl -L --output /usr/local/bin/gitlab-runner https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-amd64

        # Give it permission to execute
        chmod +x /usr/local/bin/gitlab-runner

        # Create a GitLab Runner user
        useradd --comment 'GitLab Runner' --create-home gitlab-runner --shell /bin/bash

        # Install and run as a service
        gitlab-runner install --user=gitlab-runner --working-directory=/home/gitlab-runner
        gitlab-runner start

        # Moving .bash_logout so that gitlab does not give an error
        mv /home/gitlab-runner/.bash_logout /home/gitlab-runner/.bash_logout.bak
fi

if [[ "$SSL" != [123] ]]; then
      read -n1 -p "Which linux gitlab-runner do you want to add? [ 1 - SSL / 2 - IgnoreSSL / 3 - NoSSL ]: " SSL
      echo
        if  [[ $SSL != [123] ]]; then
             echo "You must select the correct type of encryption!"
             exit
        fi
fi

if [[ "$SSL" == 3 ]]; then
      PROTOCOL="http"
      PORT=80
fi

if [[ -z "$REGISTRATION_TOKEN" ]]; then
      read -p "Enter registration token: " REGISTRATION_TOKEN
        if  [[ -z "$REGISTRATION_TOKEN" ]]; then
             echo -e "\nYou must enter registration token!"
             exit
        fi
fi

if [[ -z "$DOCKER_IMAGE" ]]; then
      DOCKER_IMAGE="ubuntu:20.04"
fi

case $EXECUTOR in
     "docker") ARGUMENTS="--docker-image $DOCKER_IMAGE --docker-cpus 1 --docker-memory 1g"
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
               fi;;
    *|"shell") EXECUTOR="shell";;
esac

ARGUMENTS="--non-interactive --url ${PROTOCOL}://${SERVER}:${PORT}/ --registration-token $REGISTRATION_TOKEN \
           --executor $EXECUTOR $ARGUMENTS --tag-list $(hostname),$EXECUTOR"
DESCRIPTION="$(hostname) $EXECUTOR"

if [[ "$SSL" == [13] ]]; then
      gitlab-runner register $ARGUMENTS --description "$DESCRIPTION"
 elif [[ "$SSL" == 2 ]]; then
      # Create the certificates hierarchy expected by gitlab
      mkdir -p $(dirname "$CERTIFICATE")
      # Get the certificate in PEM format and store it
      openssl s_client -connect ${SERVER}:${PORT} -showcerts </dev/null 2>/dev/null | sed -e '/-----BEGIN/,/-----END/!d' | tee "$CERTIFICATE" >/dev/null
      # Register your runner
      gitlab-runner register $ARGUMENTS --description "$DESCRIPTION" --tls-ca-file=$CERTIFICATE
fi
