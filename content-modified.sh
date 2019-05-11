#!/bin/bash

shead=$(date +%s -r HEAD.txt)
sbody=$(date +%s -r BODY.txt)

if [ ${shead} -gt ${sbody} ]
then
    date -r HEAD.txt
else
    date -r BODY.txt
fi
