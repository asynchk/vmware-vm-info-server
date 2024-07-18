#!/bin/sh

# Run the Ansible playbook to fetch VMware VM information
cd /vm-info/ && ansible-playbook /vm-info/playbooks/fetch_vmware_info.yml