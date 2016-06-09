#!/bin/bash
vagrant ssh $1 --command "sudo yum -y groupinstall 'Development Tools'"
vagrant ssh $1 --command "sudo yum -y install kernel-devel"
