#!/bin/bash

2>/dev/null ls -l BODY.txt | awk '{print $5}' 
