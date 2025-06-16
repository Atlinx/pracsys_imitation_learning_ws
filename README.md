# PRACSYS Imitation Learning WS
An organized collection of ROS packages for planning and control of robot manipulators at PRACSYS lab. This is specifically for the Imitation Learning project.

## Overview
- `motoman`
  - Drivers for motoman.
- `robotiq_arg95_description`
  - Drivers for Robotiq 2f85 gripper.
- `zed-ros-wrapper`
  - Drivers for ZED Mini cameras.
- `ros-noetic-ur-robot-driver` `(apt installed)`
  - Drivers for UR5e robot.
- `ros-noetic-ur-calibration` `(apt installed)`
  - Drivers for Universal Robots.

## Setup Workspace
1. Clone the repository under your catkin workspace as `src`, and then enter the `src` directory:
```
mkdir catkin_ws
cd catkin_ws
git clone https://github.com/Atlinx/pracsys_imitation_learning_ws.git src 
```
2. Install the submodules and check for dependencies:
```
./install.sh
```
3. Go into the repo directory and install dependencies:
```
rosdep install --from-paths src --ignore-src -r -y
```
