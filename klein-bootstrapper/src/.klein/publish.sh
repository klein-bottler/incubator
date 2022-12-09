#!/usr/bin/sh
# This is a portable build script
# It's intention is to allow building using pre-generated resources without requiring the klein bootstrapper
podman push quay.io/klein/klein-bootstrapper-test:latest
podman push quay.io/klein/klein-bootstrapper-test:0.0.1-dev