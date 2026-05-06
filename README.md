# PRACSYS Imitation Learning WS
A Catkin ROS workspace for the Imitation Learning repository at PRACSYS lab.

## Overview
- `motoman` - Drivers for motoman robots.
- `robotiq_arg95_description` - Drivers for the Robotiq 2f85 gripper.
- `zed-ros-wrapper` - Drivers for ZED Mini cameras.
- `lerobot` - ML robotics framework. Installed as python package.
- `gello_software` - Teleoperation framework. Installed as python package.
- `vamp` - Fast CPU-based motion planning library. Installed as python package.
- `ImitationLearning` - The main ImitationLearning repository. 
  - `Rerun` - A data visualizer. Installed as python package.
  - `ur-rtde` - API for controlling a UR5e robot. Installed as a python package.
  - `pixi` - A package/env manager.
    

## Install

1. Download and run [ws_install.sh](./ws_install.sh) to automatically setup the workspace along with required dependencies.

## Scripts

- `ws_install.sh`
  - Installs the workspace along with the required dependencies
- `catkin_build.sh`
  - Calls `catkin build`, and then `make_compile_commands.sh`
- `make_compile_commands.sh`
  - Combines the `compile_command.json` files generated within each built package into a central `build/compile_command.json` file