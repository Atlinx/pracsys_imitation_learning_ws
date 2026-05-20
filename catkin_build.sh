#!/bin/bash

CATKIN_WS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd $CATKIN_WS
catkin config --extend /opt/ros/noetic --cmake-args -DPYTHON_EXECUTABLE=/usr/bin/python3 -DCMAKE_POLICY_VERSION_MINIMUM=3.5 -DCMAKE_EXPORT_COMPILE_COMMANDS=1 -DCUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda -Wno-dev
catkin build
echo "GENERATING COMPILE COMMANDS..."
./make_compile_commands.sh