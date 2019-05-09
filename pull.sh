#!/bin/bash

remote=/storage/emulated/0/
folder=syntelos


function pull {

    cmd="adb pull -a ${remote}/${1} ${1}"
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
	if pull "${1}"
	then
	    shift
	else
	    exit 1
	fi
    done
else
    cmd="adb pull -a ${remote}/${folder} ."
    echo ${cmd}

    if ${cmd}
    then
	exit 0
    else
	echo $0 error
	exit 1
    fi
fi
