#!/bin/bash

# docker
sudo chmod 666 /var/run/docker.sock
sudo usermod -aG docker ${USER}
