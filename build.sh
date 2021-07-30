#!/bin/bash

docker build . -t ghcr.io/appacyazilim/dphphost:php8
docker push ghcr.io/appacyazilim/dphphost:php8