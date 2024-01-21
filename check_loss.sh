#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Usage: $0 configfile"
    exit
fi


num_vars=$(echo "$@" | awk '{print NF}')

if [ $num_vars -ne 1 ]; then
    num_x_lines=$(cat $1 | grep train_nll_loss | cut -d"{" -f2 | cut -d "," -f1,2 | wc -l)
    num_y_lines=$(cat $2 | grep train_nll_loss | cut -d"{" -f2 | cut -d "," -f1,2 | wc -l)
    min_lines=$(echo "$num_x_lines $num_y_lines" | awk '{print ($1 < $2) ? $1 : $2}')
    x=$(cat $1 | grep train_nll_loss | cut -d"{" -f2 | cut -d "," -f1,2 | head -n $min_lines)
    y=$(cat $2 | grep train_nll_loss | cut -d"{" -f2 | cut -d "," -f1,2 | head -n $min_lines)
    paste <(echo "$x") <(echo "$y")
    exit
fi

cat $1 | grep train_nll_loss | cut -d"{" -f2 | cut -d "," -f1,2
cat $1 | grep "shared model params"
cat $1 | grep "done training " | awk -F "done training in " "{print \$2}" | awk -F "seconds" "{print \$1/3600}"
