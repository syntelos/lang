#!/bin/bash

function reference {
    shead=$(date +%s -r HEAD.txt)
    sbody=$(date +%s -r BODY.txt)

    if [ $shead -nt $sbody ]
    then
        date -r HEAD.txt
    else
        date -r BODY.txt
    fi
}
function radiate {
    ./content-radiate.sh HEAD.txt > README.txt
}


if radiate && cat BODY.txt >> README.txt
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
