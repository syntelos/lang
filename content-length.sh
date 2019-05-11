#!/bin/bash

2>/dev/null ls -l README-body.txt | awk '{print $5}' 
