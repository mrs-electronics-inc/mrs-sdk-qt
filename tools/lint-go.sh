#!/usr/bin/env bash

set -e

cd tools/mrs-sdk-manager
go vet ./...
