
if ./content-radiate.sh HEAD.txt > README.txt && ./content-radiate.sh BODY.txt >> README.txt
then
    wc -l README.txt
    cat -n README.txt
    exit 0
else
    cat<<EOF>&2
$0 error in './content-radiate.sh HEAD.txt > README.txt && ./content-radiate.sh BODY.txt >> README.txt'
EOF
    exit 1
fi
