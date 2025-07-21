#!/bin/bash
SCRIPT_DIR="$(dirname -- "$( readlink -f -- "$0"; )")"
cd $SCRIPT_DIR

# Check dependencies
missing_deps=false
if ! lsb_release -d | grep -q "Ubuntu 20.04"; then
  echo -e "\e[31m🛑 OS is not Ubuntu 20.04. 
   Please run the installer on Ubuntu 20.04.
   See https://ubuntu.com/tutorials/install-ubuntu-desktop for a tutorial.
\e[0m"url -L https://download.stereolabs.com/zedsdk/4.2/cu12/ubuntu20 -o installer.run
  missing_deps=true
fi
if [ ! -e "/usr/local/zed/" ]; then
  echo -e "\e[31m🛑 ZED SDK is not installed. 
   Please follow instructions at https://www.stereolabs.com/docs/ros to install.
\e[0m"
  missing_deps=true
fi
if [ ! -d "/opt/ros/noetic" ]; then
  echo -e "\e[31m🛑 ROS Noetic is not installed. 
   Please follow the instructions at https://wiki.ros.org/noetic/Installation/Ubuntu to install.
\e[0m"
fi
if [ "$missing_deps" = "true" ]; then
  read -p "Installer detected missing dependencies. Would you still like to continue? (y/N): " answer
  answer=${answer:-n}

  if [[ ! "$answer" =~ ^[Yy]$ ]]; then
    exit
  fi
fi

# Install UR5 drivers
echo "Installing UR5 drivers..."
sudo apt install ros-noetic-ur-robot-driver ros-noetic-ur-calibration -y

git submodule update --init --recursive
mv zed-ros-wrapper/zed-ros-interfaces zed-ros-interfaces

# Install lerobot package
echo "Installing LeRobot package..."
cd $SCRIPT_DIR/lerobot
pip3.11 install -e .
touch CATKIN_IGNORE

# Install gello package
echo "Installing Gello package..."
cd $SCRIPT_DIR/gello_software
git submodule init
git submodule update
pip3 install -r requirements.txt
pip3 install -e .
pip3 install -e third_party/DynamixelSDK/python
touch CATKIN_IGNORE
