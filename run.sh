#!/bin/bash

DOMAIN_NAME=$1

docker run --rm -v $(pwd):/app composer install
