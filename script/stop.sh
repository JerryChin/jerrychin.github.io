#!/bin/sh

cd ../
pid=`cat my.pid`

if [ -z $pid ]; then
    echo "jekyll is not running."
else
    kill $pid;
    echo "jekyll with pid ($pid) is killed"
fi