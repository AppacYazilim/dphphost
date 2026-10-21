#!/bin/bash
set -euo pipefail

docker build . -t ghcr.io/appacyazilim/dphphost:php82
docker push ghcr.io/appacyazilim/dphphost:php82
