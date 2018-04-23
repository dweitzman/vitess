#!/bin/bash

# bazel build/run --workspace_status_command=./scripts/workspace_status.sh

echo GIT_REVISION $(git rev-parse --short HEAD)
echo GIT_BRANCH $(git rev-parse --abbrev-ref HEAD)
