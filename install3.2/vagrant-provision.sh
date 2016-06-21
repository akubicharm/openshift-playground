#!/bin/bash
DIRNAME=$(dirname $0)
RHSM_USERNAME=$(cat $DIRNAME/rhn-username)
RHSM_PASSWORD=$(cat $DIRNAME/rhn-password)
RHSM_POOLID=$(cat $DIRNAME/rhn-poolid)

vagrant ssh $1 --command "sudo subscription-manager register --username='$RHSM_USERNAME' --password='$RHSM_PASSWORD'"
vagrant ssh $1 --command "sudo subscription-manager attach --pool='$RHSM_POOLID'"
vagrant ssh $1 --command "sudo yum -y groupinstall 'Development Tools'"
vagrant ssh $1 --command "sudo yum -y install kernel-devel"
