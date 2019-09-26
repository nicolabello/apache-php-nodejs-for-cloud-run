#!/bin/bash

# Exit when any command fails
set -e

tag="nicolabello/apache-php-nodejs-for-cloud-run:latest"

docker build --rm -t "$tag" .
