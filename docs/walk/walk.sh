#!/bin/bash

project='walk'

function usage {
    cat<<EOF>&2

Synopsis

  $0 <dirn>

Description

  Named directory requires 'index.txt' which lists collection by name.
  The files listed in 'index.txt' must not have a directory path
  prefix.

Configuration

  The 'delay', 'resize', and 'colorspace' and 'contrast' options to
  imagemagick "convert" may be configured.

  Example "index.txt":

    # delay 300
    # resize 60%
    # colorspace Gray
    # -contrast
    nytimes-01.png
    nytimes-02.png
    nytimes-03.png
    nytimes-04.png
    nytimes-05.png
    nytimes-06.png


EOF
    exit 1
}

#
# (main)
#
if [ -n "${1}" ]&&[ -d "${1}" ]
then
    src=$(basename "${1}")
    idx="${src}/index.txt"
    tgt="${project}-${src}.gif"

    if [ -f "${idx}" ]&& flist=$(egrep -v '^#' "${idx}" ) &&[ -n "${flist}" ]
    then
	#
	#(conf)
	#
	configuration=$(egrep -e '^# [-+]?[a-z]+' ${idx} | sed 's/^# *//; s/^[a-z]/-&/;' | tr '\n' ' ' | sed  's/  +/ /g; s/ +$//;')
	#
	#(shell)
	#
	if [ -n "${configuration}" ]
	then
	    animation="convert ${configuration} -loop 0 ${flist} ${tgt}"
	else
	    animation="convert -loop 0 ${flist} ${tgt}"
	fi

	if cd ${src} && ${animation}
	then
	    #
	    git add ${tgt}

	    eog ${tgt} &

	    exit 0
	else
	    cat<<EOF>&2
$0 error running '${animation}' in directory '${src}'.
EOF
	    exit 1
	fi
	
    else
	cat<<EOF>&2
$0 error: file not found '${idx}', or found empty.
EOF
	exit 1
    fi
else
    usage
fi
