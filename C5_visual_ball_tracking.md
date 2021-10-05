# More info: visual ball tracking

| page useful only  to the users in the Max Planck Institute for Intelligent Systems having access to the robot lab | --- |


## Users

### What it is

The robot lab is equiped with four rgb cameras, which can be used to track the (3d) position of a table tennis ball.
The software used for this is [tennicam](https://github.com/intelligent-soft-robots/tennicam) which has been developped internally by Sebastian Gomez-Gonzalez.

The desktop "rodau" is installed with the software, and the cameras are plugged to it, ready to be used.

### How-to

- Login to rodau using the ball_tracking user. The password is written on the desktop.
- Open a terminal
- Call ```tennicam_start```. Two terminals should open. If they do not show any error message, the tracking is active.


### How to fix

If you experience any issue, you can try to run in a terminal:

- tennicam_list_cameras : check if the drivers detect the four cameras
- tennicam_ping_cameras: check if the desktop can ping the four camers
- tennicam_capture_indep: check if the desktop can use the drivers to capture pictures from the cameras
- tennicam_capture: check if the desktop can use the drivers of the cameras to capture synchronized pictures

## Installation

In case the installation on rodau has been compromized, and you need to reinstall.

### Basics requirements

- Ubuntu 20.04
- you must be part of the Intelligent Soft Robots github domain
- your ssh key must be set on github

### Requirement: Cuda 10.0

If you are at MPI-IS, add to /etc/bash.bashrc:

```
echo "- setup CUDA 10.0 to /is/software/nvidia/cuda-10.0/lib64"
export LD_LIBRARY_PATH=/is/software/nvidia/cuda-10.0/lib64
export PATH=$PATH:/is/software/nvidia/cuda-10.0/bin
export CUDA_HOME=/is/software/nvidia/cuda-10.0
```

Then open a new terminal or source:

```
source /etc/bash.bashrc
```

Alternatively, to install Cuda:

```
sudo apt install -y cuda-libraries-dev-10-1 cuda-misc-headers-10-1 cuda-minimal-build-10-1
```

### Clone the treep project

Install tree:

```
pip3 install treep
```

and clone the treep configuration:

```bash
mkdir ~/Tennicam # or any other directory of your choice
cd ~/Tennicam
git clone git@github.com:intelligent-soft-robots/treep_isr.git
treep --clone BALL_TRACKING
```

### Install additional dependencies

```bash
cd ~/Tennicam/workspace/src/tennicam/
sudo ./install_dependencies
```

As, among other things, this compiles open-cv, this runs for a while

### Compile

```bash
cd ~/Tennicam/workspace
colcon build
```

### Source the workspace

Add to ~/.bashrc:

```
echo "-sourcing tennicam"
source ~/Tennicam/workspace/setup.bash
```

and start a new terminal

### Global installation of configuration files

Tennicam requires some configuration file. To install them:

```
cd ~/Tennicam/workspace/src/tennicam/extras
sudo ./install_config
```


