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
if dir_tgt=$(last)
then

    echo ${dir_tgt}

    exit 0

else
    cat<<EOF>&2
$0 error, missing directory '${dat_tgt}-1'.
EOF
    exit 1
fi
