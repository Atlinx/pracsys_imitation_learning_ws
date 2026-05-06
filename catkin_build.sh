#!/bin/bash
catkin build
echo "GENERATING COMPILE COMMANDS..."
./make_compile_commands.sh