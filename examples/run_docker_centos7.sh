#!/bin/bash
set -e

NAME=pxnginx_centos7

docker rm -v -f $NAME
docker build -t $NAME -f examples/Dockerfile.centos7 .
docker run \
    -v $(pwd)/:/tmp/px \
    -p 8080:80 \
    -it --name $NAME $NAME
