#!/bin/bash


if [[ $1 == "open" ]] 
then
    timeout 5 ./openport.sh -l
elif [[ $1 == "close" ]] 
then
    timeout 5 ./closeport.sh -l
else
    echo "wrong"
fi