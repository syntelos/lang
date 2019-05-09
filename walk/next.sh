#!/bin/bash

#
dat_tgt=$(date +%Y%m%d)
#
function last {

    if dir=$(2>/dev/null ls -d ${dat_tgt}-* | sort -V | tail -n 1)&& [ -n "${dir}" ]&&[ -d "${dir}" ]
    then
        echo "${dir}"
        return 0
    else
        return 1
    fi
}
#
function number {

    if num=$(echo ${1} | sed "s%${dat_tgt}-%%") &&[ -n "${num}" ]&&[ 0 -lt "${num}" ]
    then
        echo "${num}"
        return 0
    else
        return 1
    fi
}
#
function next {

    if next=$(( ${1} + 1 )) &&[ ${1} -lt ${next} ]
    then
        echo "${next}"
        return 0
    else
        return 1
    fi
}
#
# 
#
if dir_tgt=$(last) && number=$(number ${dir_tgt}) && next=$(next ${number})
then

    echo ${dat_tgt}-${next}
else

    echo ${dat_tgt}-1
fi
exit 0
