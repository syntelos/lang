#!/bin/bash

function usage {
    cat<<EOF>&2

Synopsis

  $0 <opr> <file>

Description

  MIME file handling.  See 'split' & 'merge'.

Operations

  count src
  length src
  head src
  body src
  touch tgt src
  split tgt-head tgt-body src
  merge tgt src-head src-body


EOF
}
function head_lines {
    if [ -n "${1}" ]&&[ -f "${1}" ]
    then
        chk=1
        for lno in $(egrep -n '^[A-Z][-a-zA-Z]+: ' ${1} | sed 's/:.*//')
        do
            if [ $chk -eq $lno ]
            then
                chk=$(( $chk + 1 ))
            else
                break
            fi
        done

        if [ 1 -lt $chk ]
        then
            echo $chk
            return 0
        else
            return 1
        fi
    else
        return 1
    fi
}
function file_lines {
    if [ -n "${1}" ]&&[ -f "${1}" ]
    then
        wc -l "${1}" | awk '{print $1}'
        return 0
    else
        return 1
    fi
}
function file_size {
    if [ -n "${1}" ]&&[ -f "${1}" ]
    then
        ls -l "${1}" | awk '{print $5}'
        return 0
    else
        return 1
    fi
}
function copy_head {
    if count=$(head_lines "${1}")
    then
        cat "${1}" | head -n ${count}
        return 0
    else
        return 1
    fi
}
function copy_body {
    if length=$(file_lines "${1}") && count=$(head_lines "${1}")
    then
        cat "${1}" | tail -n $(( $length - $count ))
        return 0
    else
        return 1
    fi
}
function last_modified {
    egrep '^Last-Modified: ' "${1}" | sed 's/^Last-Modified: //'
}
function do_touch {

    if date=$(last_modified "${2}") && touch -d "${date}" "${1}"
    then
        return 0
    else
        return 1
    fi
}


if [ 2 -eq $# ]
then
    opr="${1}"
    src="${2}"

    case "${opr}" in
        count)
            if head_lines "${src}"
            then
                exit 0
            else
                exit 1
            fi
            ;;
        length)
            if file_lines "${src}"
            then
                exit 0
            else
                exit 1
            fi
            ;;
        head)
            if copy_head "${src}"
            then
                exit 0
            else
                exit 1
            fi
            ;;
        body)
            if copy_body "${src}"
            then
                exit 0
            else
                exit 1
            fi
            ;;
        *)
            usage
            exit 1
            ;;
    esac

elif [ 3 -eq $# ]
then
    opr="${1}"
    tgt="${2}"
    src="${3}"

    case "${opr}" in
        touch)
            if do_touch "${tgt}" "${src}"
            then
                exit 0
            else
                exit 1
            fi
            ;;
        *)
            usage
            exit 1
            ;;
    esac

elif [ 4 -eq $# ]
then
    opr="${1}"

    case "${opr}" in
        split)
            tgt_head="${2}"
            tgt_body="${3}"
            src="${4}"

            if copy_head "${src}" > "${tgt_head}" && do_touch "${tgt_head}" "${src}" &&
               copy_body "${src}" > "${tgt_body}" && do_touch "${tgt_body}" "${src}"
            then
                exit 0
            else
                exit 1
            fi
            ;;
        merge)
            tgt="${2}"
            src_head="${3}"
            src_body="${4}"

            if date=$(date) && size=$(file_size "${src_body}") && cat "${src_head}" "${src_body}" | sed "s%Last-Modified: .*%Last-Modified: ${date}%; s%Content-Length: .*%Content-Length: ${size}%;" > "${tgt}"
            then
                exit 0
            else
                exit 1
            fi
            ;;
        *)
            usage
            exit 1
            ;;
    esac
else
    usage
    exit 1
fi
