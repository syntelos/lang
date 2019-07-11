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
function message_count_meta {
    if [ -n "${1}" ]&&[ -f "${1}" ]
    then
        # count metadata lines
        #
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

        # affirm presence of metadata lines by count
        #
        if [ 1 -lt $chk ]
        then
            echo $chk
            return 0
        fi
    fi
    return 1
}
function message_head_close {
    if [ -n "${1}" ]&&[ -f "${1}" ]
    then
        # count metadata lines, as in "message_count_meta"
        #
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

        # cut everything after metadata
        #
        count=$(wc -l "${1}" | awk '{print $1}')

        if cat "${1}" | sed "${chk},${count}d" > /tmp/tmp && mv /tmp/tmp "${1}"
        then
            return 0
        fi
    fi
    return 1
}
function message_head_open {
    if [ -n "${1}" ]&&[ -f "${1}" ]
    then

        echo >> "${1}"

        return 0
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
    if count=$(message_count_meta "${1}")
    then
        cat "${1}" | head -n ${count}
        return 0
    else
        return 1
    fi
}
function copy_body {
    if length=$(file_lines "${1}") && count=$(message_count_meta "${1}")
    then
        many=$(( $length - $count ))
        if [ 0 -lt ${many} ]
        then
            cat "${1}" | tail -n ${many}
        fi
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
    if count=$(message_count_meta "${1}") && [ 0 -lt $count ]
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
            # update merge
            #
            #    for each expected metadata line, perform rewrite or append
            #
            if date=$(date -r "${1}") && size=$(file_size /tmp/body) && hash=$(file_hash /tmp/body)
            then

                for meta in Location Content-Type Content-Length Content-MD5 Date Last-Modified
                do

                    if [ -z "$(egrep -e ^${meta}: /tmp/head)" ]
                    then

                        case ${meta} in
                            Location)
                                if message_head_close /tmp/head && echo "Location: file:${1}" >> /tmp/head
                                then
                                    message_head_open /tmp/head
                                else
                                    return 1
                                fi
                                ;;
                            Content-Type)
                                if message_head_close /tmp/head && echo "Content-Type: text/plain; charset=UTF-8" >> /tmp/head
                                then
                                    message_head_open /tmp/head
                                else
                                    return 1
                                fi
                                ;;
                            Content-Length)
                                if message_head_close /tmp/head && echo "Content-Length: ${size}" >> /tmp/head
                                then
                                    message_head_open /tmp/head
                                else
                                    return 1
                                fi
                                ;;
                            Content-MD5)
                                if message_head_close /tmp/head && echo "Content-MD5: ${hash}" >> /tmp/head
                                then
                                    message_head_open /tmp/head
                                else
                                    return 1
                                fi
                                ;;
                            Date)
                                if message_head_close /tmp/head && echo "Date: ${date}" >> /tmp/head
                                then
                                    message_head_open /tmp/head
                                else
                                    return 1
                                fi
                                ;;
                            Last-Modified)
                                if message_head_close /tmp/head && echo "Last-Modified: ${date}" >> /tmp/head
                                then
                                    message_head_open /tmp/head
                                else
                                    return 1
                                fi
                                ;;
                        esac
                    else

                        case ${meta} in
                            Location)
                            ;;
                            Content-Type)
                            ;;
                            Content-Length)
                                if cat /tmp/head | sed "s%^Content-Length: .*%Content-Length: ${size}%" > /tmp/tmp
                                then
                                    mv /tmp/tmp /tmp/head
                                else
                                    return 1;
                                fi
                                ;;
                            Content-MD5)
                                if cat /tmp/head | sed "s%^Content-MD5: .*%Content-MD5: ${hash}%" > /tmp/tmp
                                then
                                    mv /tmp/tmp /tmp/head
                                else
                                    return 1
                                fi
                                ;;
                            Date)
                                ;;
                            Last-Modified)
                                if cat /tmp/head | sed "s%^Last-Modified: .*%Last-Modified: ${date}%" > /tmp/tmp
                                then
                                    mv /tmp/tmp /tmp/head
                                else
                                    return 1
                                fi
                                ;;
                        esac
                    fi
                done

                cat /tmp/head /tmp/body > "${1}"
                touch -d "${date}" "${1}"
                return 0
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
            if message_count_meta "${src}"
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
