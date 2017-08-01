#!/bin/bash

if [[ -n "$1" ]]; then
  docker rm -f twctf-01-xss
  docker run -p $1:3000 -d --name twctf-01-xss twctf-xss
  echo "Docker container should be running at port $1"
else
  echo "Argument error, please provide port number"
  echo "$0 <port number>"
fi
