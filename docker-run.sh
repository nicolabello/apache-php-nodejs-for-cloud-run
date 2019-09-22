#!/bin/bash

# Exit when any command fails
set -e

appFolder=${1:-"example-app"}

scriptPath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
#executionPath=$(pwd)
tag="$(basename "$scriptPath"):latest"

# Add --rm to build or run to remove automatically on stop
docker rm $(docker stop $(docker ps -a -q --filter "ancestor=$tag" --format="{{.ID}}")) || true
docker build --rm -t "$tag" .
docker run -d -p 90:8080/tcp -v "$scriptPath/$appFolder:/apps/$appFolder:ro" "$tag"
