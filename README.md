# PRACSYS Imitation Learning WS
An organized collection of ROS packages for planning and control of robot manipulators at PRACSYS lab. This is specifically for the Imitation Learning project.

## Setup the workspace
1. Clone the repository and all submodules and go into the repo directory:
```
mkdir catkin_ws
cd catkin_ws
git clone https://github.com/Atlinx/pracsys_imitation_learning_ws.git src 
```
2. Checkout the submodules:
```
./checkout_submodules.sh
```
3. Go into the repo directory and install dependencies:
```
rosdep install --from-paths src --ignore-src -r -y
```
