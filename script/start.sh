#!/bin/sh
cd ../


if [ $1 -a $1 = 'debug' ]; then
    jekyll serve --watch --verbose --port 8080 --host=127.0.0.1 --open-url --drafts
else
    nohup jekyll serve --watch --verbose --port 8080 --host=127.0.0.1 --open-url --drafts >  error.out 2>&1 &
    echo $! > my.pid
fi