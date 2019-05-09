#!/bin/bash

remote=/storage/emulated/0/
local=syntelos


function push {

    cmd="adb push --sync ${1} ${remote}/${1}"
    echo ${cmd}

    if ${cmd}
    then
	return 0
    else
	echo $0 error
	return 1
    fi
}

if [ -n "${1}" ]
then
    while [ -n "${1}" ]
    do
	if push "${1}"
	then
	    shift
	else
	    exit 1
	fi
    done
else
    cmd="adb push --sync ${local} ${remote}"
    echo ${cmd}

    if ${cmd}
    then
	exit 0
    else
	echo $0 error
	exit 1
    fi
fi
