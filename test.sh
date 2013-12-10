#!/bin/sh
set -x
uname -a
id
pwd
env | sort
set +x
echo $ ls /bin
echo `ls /bin`
echo $ ls /sbin
echo `ls /sbin`
echo $ ls /usr/bin
echo `ls /usr/bin`
echo $ ls /usr/sbin
echo `ls /usr/sbin`
