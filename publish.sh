#!/bin/sh
set -eu

IMAGE="kareemarafa/ionhour-checker"
VERSION="1.0.1"

# Build

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
docker build -t "$IMAGE:$VERSION" "$SCRIPT_DIR"

# Tag latest

docker tag "$IMAGE:$VERSION" "$IMAGE:latest"

# Push

docker push "$IMAGE:$VERSION"
docker push "$IMAGE:latest"
