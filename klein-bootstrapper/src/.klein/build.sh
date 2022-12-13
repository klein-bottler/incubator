#!/usr/bin/sh
set -e
# This is a portable build script
# It's intention is to allow building using pre-generated resources without requiring the klein bootstrapper
PROJECT_DIR="$(dirname -- "$(dirname -- "$( readlink -f -- "$0" )")")"
. $PROJECT_DIR/assets/utils/image_tools.sh

clear_manifest localhost/klein-bootstrapper-test:latest

BUILD_HASH="$(hash_src "$PROJECT_DIR")"
podman build \
    --manifest localhost/klein-bootstrapper-test:latest \
    --build-arg BUILD_HASH="$BUILD_HASH\n" \
    -f $PROJECT_DIR/.klein/Containerfile "$PROJECT_DIR"