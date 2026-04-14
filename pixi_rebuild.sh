# Build pixi environment
echo "✨ Building Pixi envs..."
CATKIN_WS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd $CATKIN_WS/src/ImitationLearning
pixi clean
pixi install --all
eval "$(pixi shell-hook --manifest-path $CATKIN_WS/src/ImitationLearning/pixi.toml)"

# Install LeRobot package
echo "📦 Installing LeRobot package..."
cd $CATKIN_WS/src/lerobot
pixi run -m $PIXI_PROJECT_MANIFEST -e py311 -- bash -c '
  pip install -e .
'
touch CATKIN_IGNORE

# Install Gello package
echo "📦 Installing Gello package..."
cd $CATKIN_WS/src/gello_software
pixi run -m $PIXI_PROJECT_MANIFEST -e py38 -- bash -c '
  pip install -r requirements.txt
  pip install -e .
  pip install -e third_party/DynamixelSDK/python
'
touch CATKIN_IGNORE

# Install Vamp
echo "📦 Installing Vamp package..."
rm -rf $CATKIN_WS/src/vamp/build 
cd $CATKIN_WS/src/vamp

pixi run -m $PIXI_PROJECT_MANIFEST -e py311 -- bash -c '
  pip install .
'
pixi run -m $PIXI_PROJECT_MANIFEST -e py38 -- bash -c '
  pip install .
'