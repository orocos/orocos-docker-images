#!/bin/bash
set -e

# setup orocos environment
source "/opt/orocos/eloquent/setup.bash"

exec "$@"
