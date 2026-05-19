#!/bin/sh
set -eu

AWS_REGION="${AWS_REGION:-eu-central-1}"
AWS_ACCOUNT_ID="${AWS_ACCOUNT_ID:-$(aws sts get-caller-identity --query Account --output text)}"
IMAGE="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/ionhour-checker"
VERSION="1.0.1"

# Build

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
docker build -t "$IMAGE:$VERSION" "$SCRIPT_DIR"

# Tag latest

docker tag "$IMAGE:$VERSION" "$IMAGE:latest"

# Push

aws ecr get-login-password --region "$AWS_REGION" \
  | docker login --username AWS --password-stdin "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"
docker push "$IMAGE:$VERSION"
docker push "$IMAGE:latest"
