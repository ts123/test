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
cmd 'echo `ls /bin`'
cmd 'echo `ls /sbin`'
cmd 'echo `ls /usr/bin`'
cmd 'echo `ls /usr/sbin`'
cmd 'echo `ls /usr/local/bin`'
cmd 'echo `ls /usr/local/sbin`'

