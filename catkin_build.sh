#!/bin/bash

CATKIN_WS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd $CATKIN_WS
catkin build
echo "GENERATING COMPILE COMMANDS..."
./make_compile_commands.sh