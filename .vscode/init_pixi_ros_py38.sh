# VS Code bash init file for Pixi py38 + ROS Noetic.
#
# This is necessary because the Pixi environments fails to include the 
# custom bash aliases (roscd, etc.) from rosbash when devel/setup.bash is sourced.

if [ -f "$HOME/.bashrc" ]; then
  source "$HOME/.bashrc"
fi

_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_WORKSPACE_ROOT="$(cd "${_SCRIPT_DIR}/.." && pwd)"
_ROS_SETUP="${_WORKSPACE_ROOT}/devel/setup.bash"

if command -v pixi >/dev/null 2>&1; then
  eval "$(pixi shell-hook -m "${_WORKSPACE_ROOT}/src/ImitationLearning/pixi.toml" -e py38)"
fi

if [ -f "${_ROS_SETUP}" ]; then
  source "${_ROS_SETUP}"
fi
