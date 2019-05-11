#!/bin/bash

function reference {
    shead=$(date +%s -r README-head.txt)
    sbody=$(date +%s -r README-body.txt)

    if [ $shead -nt $sbody ]
    then
        date -r README-head.txt
    else
        date -r README-body.txt
    fi
}
function radiate {
    ./content-radiate.sh README-head.txt > README.txt
}


if radiate && cat README-body.txt >> README.txt
then
    touch -d "$(reference)" README.txt

    wc -l README.txt
    cat -n README.txt
    exit 0
else
    cat<<EOF>&2
$0 error in './content-radiate.sh HEAD.txt > README.txt && ./content-radiate.sh BODY.txt >> README.txt'
EOF
    exit 1
fi
