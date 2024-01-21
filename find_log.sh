#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 search term"
    exit
fi


find examples/wav2vec/outputs/ -iname *.log | xargs grep -E "$1" | grep "Saved checkpoint" 