#!/usr/bin/sh
# This is a portable build script
# It's intention is to allow building using pre-generated resources without requiring the klein bootstrapper
PROJECT_DIR="$(dirname -- "$(dirname -- "$( readlink -f -- "$0" )")")"
podman build \
    -t quay.io/klein/klein-bootstrapper-test:latest \
    -t quay.io/klein/klein-bootstrapper-test:0.0.1-dev \
    -f $PROJECT_DIR/.klein/Dockerfile $PROJECT_DIR