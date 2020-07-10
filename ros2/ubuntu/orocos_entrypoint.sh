#!/bin/bash
set -e

# Setup ros2 and orocos environment
source "/opt/ros/$ROS_DISTRO/setup.sh"
[ -d "/opt/orocos/$ROS_DISTRO" ] && source "/opt/orocos/$ROS_DISTRO/local_setup.sh"

# Append commands to setup ros2 and orocos environment to ~/.bashrc.
# This is only relevant if the command to be executed ("$@") is an interactive bash shell.
# Or for later `docker exec -it bash`.
# It is not sufficient to source bash-specific setup scripts here, because bash is executed as
# a new process. Aliases, command-line completion etc. configured here would have no effect.
if ! grep -q '# setup ros2 and orocos environment' ~/.bashrc >/dev/null; then
  cat >>~/.bashrc <<'EOF'

# setup ros2 and orocos environment
source "/opt/ros/$ROS_DISTRO/setup.bash"
[ -d "/opt/orocos/$ROS_DISTRO" ] && source "/opt/orocos/$ROS_DISTRO/local_setup.bash"
EOF
fi

exec "$@"
