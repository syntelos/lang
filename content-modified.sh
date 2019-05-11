#!/bin/bash

shead=$(date +%s -r README-head.txt)
sbody=$(date +%s -r README-body.txt)

if [ ${shead} -gt ${sbody} ]
then
    date -r README-head.txt
else
    date -r README-body.txt
fi
