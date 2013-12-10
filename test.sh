#!/bin/sh
set -x
uname -a
id
pwd
env | sort
set +x
echo
echo $ ls /bin
echo `ls /bin`
echo
echo $ ls /sbin
echo `ls /sbin`
echo
echo $ ls /usr/bin
echo `ls /usr/bin`
echo
echo $ ls /usr/sbin
echo `ls /usr/sbin`

