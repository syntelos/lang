#!/bin/bash

function usage {
    cat<<EOF>&2

Synopsis

  $0 <opr> <file>

Description

  MIME file handling.  

  The operation 'import' adds headers to a plain text file, presuming
  a UTF-8 encoding.  The operations 'split' & 'merge' handle the
  radiant object as independent parts.  The operation 'update'
  reflects the content length and last modified from the file system
  object.

Operations

  body src
  count src
  hash src
  head src
  import src
  length src
  merge tgt src-head src-body
  touch tgt src
  split tgt-head tgt-body src
  update src
  check src

EOF
}
function head_lines {
    if [ -n "${1}" ]&&[ -f "${1}" ]
    then
        chk=1
        for lno in $(egrep -n '^[A-Z][-a-zA-Z0-9]+: ' ${1} | sed 's/:.*//')
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
        fi
    fi
    return 1
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
function file_hash {
    if [ -n "${1}" ]&&[ -f "${1}" ]
    then
        if cat "${1}" | openssl dgst -binary -md5 | base64
        then
            return 0
        fi
    fi
    return 1
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
function meta_lastmod {
    egrep '^Last-Modified: ' "${1}" | sed 's/^Last-Modified: //'
}
function meta_md5 {
    egrep '^Content-MD5: ' "${1}" | sed 's/^Content-MD5: //'
}
function do_touch {

    if date=$(meta_lastmod "${2}") && touch -d "${date}" "${1}"
    then
        return 0
    else
        return 1
    fi
}
function do_import {
    if count=$(head_lines "${1}") && [ 0 -lt $count ]
    then
        return 1

    elif date=$(date -r "${1}") && size=$(file_size "${1}") && hash=$(file_hash "${1}")
    then
        cat<<EOF>/tmp/tmp
Location: file:${1}
Content-Type: text/plain; charset=UTF-8
Content-Length: ${size}
Content-MD5: ${hash}
Date: ${date}
Last-Modified: ${date}

EOF
        if cat "${1}" >> /tmp/tmp && cp /tmp/tmp "${1}" && touch -d "${date}" "${1}"
        then
            return 0
        else
            return 1
        fi
    else
        return 1
    fi
}
function do_update {
    # split
    if copy_head "${1}" > /tmp/head
    then
        if copy_body "${1}" > /tmp/body
        then
            #merge
            if date=$(date -r "${1}") && size=$(file_size /tmp/body) && hash=$(file_hash /tmp/body)
            then

                if cat /tmp/head | sed "s%^Last-Modified: .*%Last-Modified: ${date}%; s%^Content-Length: .*%Content-Length: ${size}%; s%^Content-MD5: .*%Content-MD5: ${hash}%;" > "${1}" && cat /tmp/body >> "${1}"
                then
                    touch -d "${date}" "${1}"

                    return 0
                fi
            fi
        fi
    fi
    return 1
}
function do_check {
    # split
    if copy_head "${1}" > /tmp/head
    then
        if copy_body "${1}" > /tmp/body
        then
            #diff
            if date=$(date -r "${1}") && size=$(file_size /tmp/body) && hash=$(file_hash /tmp/body)
            then

                if cat /tmp/head | sed "s%^Last-Modified: .*%Last-Modified: ${date}%; s%^Content-Length: .*%Content-Length: ${size}%; s%^Content-MD5: .*%Content-MD5: ${hash}%;" > /tmp/check && cat /tmp/body >> /tmp/check && [ -z "$(diff /tmp/check "${1}" )" ]
                then
                    return 0
                fi
            fi
        fi
    fi
    return 1
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
        hash)
            if file_hash "${src}"
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
        import)
            if do_import "${src}"
            then
                exit 0
            else
                exit 1
            fi
            ;;
        update)
            if do_update "${src}"
            then
                exit 0
            else
                exit 1
            fi
            ;;
        check)
            if do_check "${src}"
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

            if date=$(date) && size=$(file_size "${src_body}") && cat "${src_head}" | sed "s%^Last-Modified: .*%Last-Modified: ${date}%; s%^Content-Length: .*%Content-Length: ${size}%;" > "${tgt}" && cat "${src_body}" >> "${tgt}"
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
