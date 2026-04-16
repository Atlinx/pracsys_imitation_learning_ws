#!/bin/bash
# Installs the development environment in Ubuntu 20.04 (Focal)
DEBIAN_FRONTEND=noninteractive
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"


# Function that prints usage information
function usage() {
 echo -e "\e[36m🌊 Workspace Installer

Usage:  ./ws_install.sh [flags]

Flags:
  -h              Prints this help window.
  
  -g  [prefix]    Configures the method of cloning GitHub repos. 
      [prefix] = 'https', 'ssh', 'gh', or a custom prefix string like
        'git clone git@github-custom.com:'. Defaults to 'https'.
  
  -c  [ws]        Configures the folder to use as the catkin workspace.
      [ws] = File path to folder. Defaults to = '~/catkin_ws'.

  -d              Install debug tools like vim, etc.

  -b              Update the .bashrc file to source the ROS and catkin 
                  workspace setup.sh files.
\e[0m"
}

# Function to check if a flag has an argument.
function has_argument() {
  [[ ("$1" == *=* && -n ${1#*=}) || ( ! -z "$2" && "$2" != -*) ]];
}

# Function to extract the argument for a flag.
function extract_argument() {
  echo "${2:-${1#*=}}"
}

# Function to handle options and arguments
function handle_options() {
  # Initialize an array for unknown arguments if you want to collect them
  # UNKNOWN_ARGS=()

  # Process options using getopts
  # 'h' for help, 'c:' for catkin-ws (requires an argument), 'g:' for gh-clone (requires an argument)
  UPDATE_BASHRC=false
  DEBUG_TOOLS=false
  while getopts "hc:g:bd" opt; do
    case $opt in
      h)
        usage
        exit 0
        ;;
      c)
        CATKIN_WS="$OPTARG"
        ;;
      g)
        local gh_clone_method="$OPTARG" # Use a local variable for the method
        case "$gh_clone_method" in
          https)
            GH_CLONE="git clone https://github.com/"
            ;;
          ssh)
            GH_CLONE="git clone git@github.com:"
            ;;
          gh)
            GH_CLONE="gh repo clone "
            ;;
          *)
            GH_CLONE="$gh_clone_method" # Assign the argument directly if it's not a known method
            ;;
        esac
        ;;
      b)
        UPDATE_BASHRC=true
        ;;
      d)
        DEBUG_TOOLS=true
        ;;
      \?) # Invalid option
        echo -e "\e[31m🛑 Invalid option: -$OPTARG\e[0m\n" >&2
        usage # Show usage on error
        exit 1
        ;;
      :) # Missing argument for an option
        echo -e "\e[31m🛑 Option -$OPTARG requires an argument.\e[0m\n" >&2
        usage # Show usage on error
        exit 1
        ;;
    esac
  done

  # Shift off the options that have been processed by getopts
  # This leaves only non-option arguments in "$@"
  shift $((OPTIND - 1))
}


handle_options "$@"

if [[ -z "$CATKIN_WS" ]]; then
  CATKIN_WS="$HOME/catkin_ws"
fi
if [[ -z "$GH_CLONE" ]]; then
  GH_CLONE="git clone https://github.com/"
fi

IS_WSL=false
if grep -qi microsoft /proc/version; then
  IS_WSL=true
fi

export CATKIN_WS
export GH_CLONE
export IS_WSL

echo -e "\e[36m🌊 Installing workspace:
  CATKIN_WS:     ${CATKIN_WS}
  GH_CLONE:      ${GH_CLONE}
  UPDATE_BASHRC: ${UPDATE_BASHRC}
  DEBUG_TOOLS:   ${DEBUG_TOOLS}
  IS_WSL:        ${IS_WSL}

  Run \`./ws_install.sh -h\` for usage.
\e[0m"
echo "Press any key to continue..."
read -n 1 -s -r
if ! sudo -v; then
  echo -e "\e[31m🛑 ERROR: Sudo privileges not granted. Exiting.\e[0m"
  exit 1 # Exit with a non-zero status to indicate failure
fi


cd $SCRIPT_DIR

if [[ "$(lsb_release -rs)" != "20.04" ]]; then
  echo -e "\e[31m🛑 ERROR: Linux distro must be Ubuntu 20.04 (focal)!\e[0m"
fi

echo "🧰 Setting up Imitation Learning workspace..."


if [[ -d "$CATKIN_WS" ]]; then
  read -p "Catkin workspace already exists @ $CATKIN_WS. Would you like to remove the workspace and reinstall? (y/N): " answer
  answer=${answer:-n}

  if [[ ! "$answer" =~ ^[Yy]$ ]]; then
    exit
  fi

  rm -rf $CATKIN_WS
fi

sudo apt-get update
sudo apt-get install curl -y




# Install Pixi
echo "📦 Installing Pixi"
if ! command -v "pixi" &>/dev/null; then
  curl -fsSL https://pixi.sh/install.sh | bash
  export PATH="$HOME/.pixi/bin:$PATH"
else
  echo "  Pixi already installed — Skipping..."
fi
# Exit if we are in a PIXI shell, since that can mess with the installation
if [[ "$PIXI_IN_SHELL" == "1" ]]; then
  echo -e "\e[31m🛑 Detected active pixi env: \"$PIXI_ENVIRONMENT_NAME\". Please the pixi shell exit before running ws_install.sh.\e[0m\n" >&2
  exit
fi




# Install ROS noetic
echo "🤖 Installing ROS"
if [[ ! -d "/opt/ros/noetic" ]]; then
  sudo sh -c 'sudo echo "deb http://packages.ros.org/ros/ubuntu focal main" > /etc/apt/sources.list.d/ros-latest.list'
  curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -
  sudo apt-get update
  sudo apt-get install ros-noetic-desktop-full python3-rosdep -y
  sudo rosdep init
else
  echo "  ROS already installed — Skipping..."
fi




# Install Catkin
echo "🐱 Installing Catkin"
if ! command -v catkin &>/dev/null; then
  sudo apt-get install python3-catkin-tools -y
else
  echo "  Catkin already installed — Skipping..."
fi
source /opt/ros/noetic/setup.bash




# Install CUDA globally
echo "👽 Installing CUDA 12.8"
if ! command -v "nvcc" &>/dev/null; then
  if [[ "$IS_WSL" == true ]]; then
    CUDA_URL=https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/cuda-keyring_1.1-1_all.deb
  else
    CUDA_URL=https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-keyring_1.1-1_all.deb
  fi
  wget -O /tmp/cuda-keyring_1.1-1_all.deb $CUDA_URL
  sudo dpkg -i /tmp/cuda-keyring_1.1-1_all.deb
  sudo apt-get update
  sudo apt-get -y install cuda-toolkit-12-8
  export PATH="/usr/local/cuda-12.8/bin:$PATH"
  if ! grep -Fxq "export PATH=\"/usr/local/cuda-12.8/bin:\$PATH\"" ~/.bashrc; then
    echo "export PATH=\"/usr/local/cuda-12.8/bin:\$PATH\"" >> ~/.bashrc
  fi
else

  echo "  CUDA already installed — Skipping..."
fi





# Install ZED SDK
echo "🦓 Installing ZED SDK (CUDA 12.X)"
if [[ ! -e "/usr/local/zed/" ]]; then
  sudo apt-get install zstd -y
  curl -L https://download.stereolabs.com/zedsdk/5.0/cu12/ubuntu20 -o zed_installer.run
  chmod +x zed_installer.run
  ./zed_installer.run -- silent
  rm ./zed_installer.run
else
  echo "  ZED SDK already installed — Skipping..."
fi




# Install Pracsys Workspace 
echo "🚧 Installing Pracsys Workspace"
sudo apt-get install git -y
${GH_CLONE}Atlinx/pracsys_imitation_learning_ws $CATKIN_WS
git checkout master
git pull # Fetch the latest version, since ImitationLearning changes frequently
cd $CATKIN_WS
git submodule update --init --recursive
cd $CATKIN_WS/src
mv zed-ros-wrapper/zed-ros-interfaces zed-ros-interfaces
cd $CATKIN_WS
export CATKIN_WS_PIXI="$CATKIN_WS/src/ImitaitonLearning/.pixi"
catkin init
catkin config --extend /opt/ros/noetic --cmake-args -DPYTHON_EXECUTABLE=/usr/bin/python3 -DCMAKE_POLICY_VERSION_MINIMUM=3.5 -DCUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda



# Install dependencies
echo "📦 Installing ROS Dependencies"
# Vamp dependencies are included in this package list.
sudo apt-get install ros-noetic-industrial-msgs \
  ros-noetic-soem \
  ros-noetic-industrial-core \
  ros-noetic-industrial-robot-status-interface \
  ros-noetic-scaled-joint-trajectory-controller \
  ros-noetic-speed-scaling-interface \
  ros-noetic-speed-scaling-state-controller \
  ros-noetic-cv-bridge \
  ros-noetic-socketcan-interface \
  ros-noetic-dynamic-reconfigure \
  ros-noetic-message-generation \
  ros-noetic-message-runtime \
  ros-noetic-roscpp \
  ros-noetic-std-msgs \
  libeigen3-dev \
  tmux cmake -y
# Fetch build dependencies for catkin packages using rosdep
cd $CATKIN_WS
rosdep update --rosdistro=noetic
rosdep install --from-paths src --ignore-src -r -y
# Rerun dependencies
echo "📦 Installing Rerun dependencies..."
sudo apt-get -y install \
  libclang-dev \
  libatk-bridge2.0 \
  libfontconfig1-dev \
  libfreetype6-dev \
  libglib2.0-dev \
  libgtk-3-dev \
  libssl-dev \
  libxcb-render0-dev \
  libxcb-shape0-dev \
  libxcb-xfixes0-dev \
  libxkbcommon-dev \
  libxkbcommon-x11-0 \
  patchelf
# Rerun WSL dependencies
if [[ "$IS_WSL" == true ]]; then
  sudo add-apt-repository ppa:kisak/turtle -y
  sudo apt-get update
  sudo apt-get install -y mesa-vulkan-drivers
fi

# Ignore Motoman packages
echo "📦 Installing Motoman package..."
cd $CATKIN_WS/src/motoman
./ignore_pkgs.sh




# Build Pixi env
cd $CATKIN_WS
./pixi_rebuild.sh




# Download ycb models
echo "📦 Downloading YCB models..."
cd $CATKIN_WS/src/ImitationLearning
./xmls/objects/ycb/download_models.sh




# Build Catkin
echo "🐱 Build Catkin"
source ~/.bashrc
cd $CATKIN_WS
catkin build
source $CATKIN_WS/devel/setup.bash




# Install debug tools
if [[ "$DEBUG_TOOLS" == true ]]; then
  echo "🦗 Install Debug tools"
  sudo apt-get install nano neovim vim tree -y
  PS1_ECHO='export PS1="\[$(tput setaf 165)\]\u\[$(tput setaf 171)\]@\[$(tput setaf 213)\]\h \[$(tput setaf 219)\]\w \[$(tput sgr0)\]$ "'
  if ! grep -Fxq "$PS1_ECHO" ~/.bashrc; then
    echo "$PS1_ECHO" >> ~/.bashrc
  fi
  PATH_ECHO='export PATH="$HOME/.local/bin:$PATH"'
  if ! grep -Fxq "$PATH_ECHO" ~/.bashrc; then
    echo "$PATH_ECHO" >> ~/.bashrc
  fi
else
  echo "Skipping Debug tools..."
fi




# Setup bashrc
if [[ "$UPDATE_BASHRC" == "True" ]]; then
  if ! grep -Fxq "source $CATKIN_WS/devel/setup.bash" ~/.bashrc; then
    echo "source $CATKIN_WS/devel/setup.bash" >> ~/.bashrc
  fi
  if ! grep -Fxq "source /opt/ros/noetic/setup.bash" ~/.bashrc; then
    echo "source /opt/ros/noetic/setup.bash" >> ~/.bashrc
  fi
  echo "Setup bashrc."
else
  echo "Skipping setting up bashrc."
fi




echo -e "\e[32m✅ Install done!\e[0m"
if [[ "$UPDATE_BASHRC" != "True" ]]; then
  echo -e "\e[33m⚠️ ./bashrc was not updated. Remember to run \`source $CATKIN_WS/devel/setup.bash\` before running \`catkin build\`.\e[0m"
fi

echo "📩 To enter the repo, run:

  cd $CATKIN_WS/src/ImitationLearning"
