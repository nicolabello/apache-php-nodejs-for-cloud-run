#!/bin/bash

# Exit when any command fails
set -e

tag="nicolabello/apache-php-nodejs-for-cloud-run:latest"

# Build
docker build --pull --rm -t "$tag" .
