#!/bin/bash

CATKIN_WS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Folders in src to ignore
IGNORE_FOLDERS=(
  "curobo"
  "Fast-FoundationStereo"
  "gello_software"
  "Grounded-SAM-2-iterative"
  "Kalib"
)

# Create CATKIN_IGNORE files
for folder in "${IGNORE_FOLDERS[@]}"; do
  touch "$CATKIN_WS/src/$folder/CATKIN_IGNORE"
done

cd $CATKIN_WS
catkin config --extend /opt/ros/noetic --cmake-args -DPYTHON_EXECUTABLE=/usr/bin/python3 -DCMAKE_POLICY_VERSION_MINIMUM=3.5 -DCMAKE_EXPORT_COMPILE_COMMANDS=1 -DCUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda -Wno-dev
catkin build
echo "GENERATING COMPILE COMMANDS..."
./make_compile_commands.sh