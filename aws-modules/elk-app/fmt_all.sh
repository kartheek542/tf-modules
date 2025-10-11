#!/bin/bash

dirs=$(ls -l | grep "^d" | awk '{print $NF}')

while read -r line;
do
    echo "formatting $line"
    cd $line
    terraform fmt
    cd ..
done <<< $dirs
