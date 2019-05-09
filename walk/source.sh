#!/bin/bash
#
# 
#
dir_src=~/Pictures
dat_src=$(date +%Y-%m-%d)
dat_tgt=$(date +%Y%m%d)
#
# 
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
# 
#
function fetch {

    if [ -n "${1}" ]&&[ -d "${1}" ]
    then
        dir_tgt="${1}"
        index_tgt=${dir_tgt}/index.txt

        if [ ! -f ${index_tgt} ]
        then
            cat<<EOF>${index_tgt}
# delay 300
# resize 60%
EOF
            git add ${index_tgt}
        fi

        for srcf in $(2>/dev/null ls ${dir_src}/Screenshot\ from\ ${dat_src}* | sed 's/ /%%%/g;')
        do 
            srcf=$(echo $srcf | sed 's/%%%/ /g')

            tgtn=walk-$(echo $srcf | sed 's%.*Screenshot from %%; s%-%%g; s% %-%g;')

            tgtf=${dir_tgt}/${tgtn}

            echo mv "${srcf}" "${tgtf}"

            if mv "${srcf}" "${tgtf}"
            then
                git add "${tgtf}"

                echo "${tgtn}" >> ${index_tgt}
            fi
        done

        return 0
    else
        return 1
    fi
}
#
# 
#
if dir_tgt=$(last)
then

    if fetch ${dir_tgt}
    then
        exit 0
    else
        exit 1
    fi

else
    cat<<EOF>&2
$0 error, missing directory '${dat_tgt}-1'.
EOF
    exit 1
fi
