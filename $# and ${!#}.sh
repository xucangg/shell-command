#!/bin/bash

if [ $# -ne 2 ]
then
    echo
    echo Usge: shell4.sh ab
    echo
else
    total=$[ $1 + $2 ]
    echo
    echo The total is $total
    echo
fi
echo There were ${!#} parameters supplied.
