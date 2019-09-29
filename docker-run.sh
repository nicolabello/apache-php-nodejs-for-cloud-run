#!/bin/bash

# Exit when any command fails
set -e

tag="nicolabello/apache-php-nodejs-for-cloud-run:latest"

# Stop, build and run
docker rm $(docker stop $(docker ps -a -q --filter "ancestor=$tag" --format="{{.ID}}")) || true
docker build --rm -t "$tag" .
docker run -d -p 90:8080/tcp -t "$tag"
