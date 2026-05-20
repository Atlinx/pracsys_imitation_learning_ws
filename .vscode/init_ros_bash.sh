# VS Code bash init file for ROS Noetic.

if [ -f "$HOME/.bashrc" ]; then
  source "$HOME/.bashrc"
fi

_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_WORKSPACE_ROOT="$(cd "${_SCRIPT_DIR}/.." && pwd)"
_ROS_SETUP="${_WORKSPACE_ROOT}/devel/setup.bash"

if [ -f "${_ROS_SETUP}" ]; then
  source "${_ROS_SETUP}"
fi
