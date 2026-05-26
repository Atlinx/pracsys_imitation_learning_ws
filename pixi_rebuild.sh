#!/usr/bin/env bash

set -euo pipefail

CATKIN_WS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PIXI_MANIFEST_PATH="$CATKIN_WS/src/ImitationLearning/pixi.toml"

install_lerobot() {
  echo "📦 Installing LeRobot package..."
  cd "$CATKIN_WS/src/lerobot"
  pixi run -m "$PIXI_PROJECT_MANIFEST" -e py311 -- bash -c '
    pip install . --user
  '
  touch CATKIN_IGNORE
}

install_gello() {
  echo "📦 Installing Gello package..."
  cd "$CATKIN_WS/src/gello_software"
  pixi run -m "$PIXI_PROJECT_MANIFEST" -e py38 -- bash -c '
    pip install -r requirements.txt --user
    pip install .
    pip install third_party/DynamixelSDK/python
  '
  touch CATKIN_IGNORE
}

install_vamp() {
  echo "📦 Installing Vamp package..."
  rm -rf "$CATKIN_WS/src/vamp/build"
  cd "$CATKIN_WS/src/vamp"

  pixi run -m "$PIXI_PROJECT_MANIFEST" -e py311 -- bash -c '
    pip install .
  '
  pixi run -m "$PIXI_PROJECT_MANIFEST" -e py38 -- bash -c '
    pip install .
  '
}

install_curobo() {
  echo "📦 Installing curobo package..."
  cd "$CATKIN_WS/src/curobo"

  pixi run -m "$PIXI_PROJECT_MANIFEST" -e py311 -- bash -c '
    pip install .[cu12]
  '
}

generate_stubs() {
  echo "📦 Generating stubs..."
  cd "$CATKIN_WS/src/ImitationLearning"

  ./tools/generate_py_stubs.sh
}

install_package() {
  case "$1" in
    lerobot)
      install_lerobot
      ;;
    gello|gello_software)
      install_gello
      ;;
    vamp)
      install_vamp
      ;;
    curobo)
      install_curobo
      ;;
    stubs)
      generate_stubs
      ;;
    *)
      echo "❌ Unknown package: $1"
      echo "Valid options: lerobot gello vamp curobo stubs"
      exit 1
      ;;
  esac
}

cd "$CATKIN_WS/src/ImitationLearning"

if [[ $# -eq 0 ]]; then
  echo "✨ Building Pixi envs..."
  pixi clean
  pixi install --all
  eval "$(pixi shell-hook --manifest-path "$PIXI_MANIFEST_PATH")"

  install_lerobot
  install_gello
  install_vamp
  install_curobo
  generate_stubs
else
  echo "🔧 Activating Pixi shell hook..."
  eval "$(pixi shell-hook --manifest-path "$PIXI_MANIFEST_PATH")"

  for pkg in "$@"; do
    install_package "$pkg"
  done
fi
