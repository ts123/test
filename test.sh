#!/bin/sh
cmd() {
    echo
    echo $ $@
    eval $@
}
cmd uname -a
cmd id
cmd pwd
cmd 'env | sort'
cmd ls /bin
cmd ls /sbin
cmd ls /usr/bin
cmd ls /usr/sbin
cmd ls /usr/local/bin
cmd ls /usr/local/sbin

