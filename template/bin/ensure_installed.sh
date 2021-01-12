#!/bin/bash
CMD=$1
if ! [ -x "$(command -v $CMD)" ]; then
    if ! [ -x "$(command -v brew)" ]; then
        echo "required command '$CMD' not found and brew not available to install it"
        exit 1
    fi
    echo "required command '$CMD' not found. Installing..."
    brew update && brew install $CMD
fi