#!/bin/sh
sudo apt-get update  # To get the latest package lists
sudo apt-add-repository ppa:ansible/ansible
sudo apt-get update
sudo apt-get install ansible -y
#etc.