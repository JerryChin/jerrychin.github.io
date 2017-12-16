#!/bin/sh
cd ../


if [ $1 -a $1 = 'debug' ]; then
    jekyll serve --watch --verbose --port 8080 --open-url --drafts
else
    nohup jekyll serve --watch --verbose --port 8080 --open-url --drafts >  error.out 2>&1 &
    echo $! > my.pid
fi