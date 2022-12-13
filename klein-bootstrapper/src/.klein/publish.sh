#!/usr/bin/sh
# This is a portable build script
# It's intention is to allow building using pre-generated resources without requiring the klein bootstrapper
podman manifest push --all localhost/klein-bootstrapper-test quay.io/klein/klein-bootstrapper-test:latest
podman manifest push --all localhost/klein-bootstrapper-test quay.io/klein/klein-bootstrapper-test:0.0.1-dev