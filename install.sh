#!/usr/bin/bash

# Check dependencies
missing_deps=false
if ! lsb_release -d | grep -q "Ubuntu 20.04"; then
  echo -e "\e[31m🛑 OS is not Ubuntu 20.04. 
   Please run the installer on Ubuntu 20.04.
   See https://ubuntu.com/tutorials/install-ubuntu-desktop for a tutorial.
\e[0m"
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

sudo apt install ros-noetic-ur-robot-driver ros-noetic-ur-calibration

git submodule update --init --recursive