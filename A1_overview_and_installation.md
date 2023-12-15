# Overview and software installation

## Overview

![pam robot](https://ei.is.tuebingen.mpg.de/uploads/publication/image/18667/2PAMcompressed.jpg)

PAM robot (Pneumatic Artificial Muscle robot) is a four degrees of freedom robot. Most of the days, we have it learning how to play tennis table. But it could be used for other purposes, e.g. exploring the control of artificial muscles.

It is controlled via the value of pressures of its 8 artificial muscles. Each joint is connected to 2 artificial muscles, called agonist and antagonist. If the pressure of the agonist is higher than the pressure of the antagonist (i.e. the agonist is more contracted than the antagonist), the joint moves left. A control command consists of setting the pressure(s) of one (or more) muscle(s).

We developed some software allowing for the control of the robot (or a [MuJoCo](http://www.mujoco.org/) simulated version of it). The software allows to send commands related to the desired pressures to the robot, as well as accessing the current and past states of the robot. The software is written in C++ and has Python wrappers (and has been tested only on Ubuntu).

Once the software installed, the typical workflow starts with calling in a terminal:

For starting the real robot:

```bash
o80_pam
```

For starting a simulated robot:

```bash
pam_mujoco mujoco_id
# arbritrary_id is an arbitrary string used
# to distinguish between all the simulated robots
# that may run in parallel
```

The command above spawns a "backend" process which connects to the robot. This process reads continuously (i.e. at a frequency of 200Hz or more) the state of the robot and writes it in a shared memory. Also, it reads the shared memory for commands to apply to the robot. 

User may then use a Python (or a C++) API for interacting with the shared memory, i.e. reading the state of the robot (written by the backend) or writing commands to it (which will then be read by the backend and applied to the robot).

There are quite a few types of commands that can be written in the shared memory. The system is based on o80, and it is advised to read o80's {doc}`documentation <o80:index>` before going further.

## Software installation 

Installing the software will results in:

- having some executables installed on your system (e.g. 'o80_pam' or 'pam_mujoco' already mentioned above)
 
- having some Python packages installed
 
- useful for advanced users: some C++ libraries installed

The executables will be used to start the backend connecting to the robot, while the Python packages can be used for developers to create control scripts that send commands to the backend (via the shared memory) and/or read states of the robot (also via the shared memory).

### Using the installation script

#### Requirements

- recommanded: activate a dedicated python virtual environment
- install the development package of the python version you use, e.g. ```sudo apt install python3.9-dev```
- upgrade pip to latest version: ```pip install --upgrade pip```

#### Steps

- clone https://github.com/intelligent-soft-robots/hysr
- pip install (```cd hysr && pip install .```)
- run in a terminal ```hysr_pam_install```. This will prompt you for your (sudo) password. Sudo rights are required by the script because it installs some dependencies using apt.
- open a new terminal. Running for example ```o80_dummy``` should work. ```import pam_mujoco``` in python code should also work.

### Via colcon workspace

This is the recommended way for developers of the PAM software (as opposed to the users of it).

[Colcon](https://colcon.readthedocs.io/en/released/) is the built system of [ROS2](https://docs.ros.org/en/foxy/index.html).
The instructions below will result in the setup of a colcon workspace. Possibly, if you would like to use o80 in a ROS2 project, you may copy the cloned packages to an existing workspace.

#### Adding your SSH key to github

See: [github documentation](https://help.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh).

All the following instructions assume your SSH key has been activated, i.e.:

```bash
# replace id_rsa by your key file name
ssh-add ~/.ssh/id_rsa
```

- You must first register your SSH key to Github. See instructions [here](https://docs.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)

- treep is likely to be already installed on your machine. If not:
```bash
pip install treep
```

#### Dependencies and configuration folder

in a terminal:

```bash
mkdir /tmp/pam && cd /tmp/pam
wget http://people.tuebingen.mpg.de/mpi-is-software/pam/resources/apt-dependencies
wget http://people.tuebingen.mpg.de/mpi-is-software/pam/resources/pip3-dependencies
chmod +x ./apt-dependencies
chmod +x ./pip3-dependencies
sudo ./apt-dependencies
./pip3-dependencies
```

#### Cloning the repositories

Creating a folder and cloning the treep configuration:

```bash
mkdir Software # you may use another folder name
cd Software
git clone git@github.com:intelligent-soft-robots/treep_isr.git
```

Cloning all the required repositories:

```bash
treep --clone PAM_MUJOCO
```

#### Compilation

```bash
cd /path/to/Software
cd workspace
colcon build --cmake-args -DCMAKE_BUILD_TYPE=Release -DPYBIND11_TEST=OFF --no-warn-unused-cli
```


This will result in a "install" folder containing the compiled binaries

### Activating the workspace

In each new terminal, the workspace needs to be sourced:

```bash
source /path/to/Software/workspace/install/setup.bash
```
```{note}
Possibly, you may want to add the line above to the ~/.bashrc file (so that each new terminal source the workspace automatically).
```

###  Checking things are ok

In a python3 terminal:

```python
import o80
import o80_pam
import pam_mujoco
import context
```
You may also try in a terminal:

```bash
pam_mujoco test
```
