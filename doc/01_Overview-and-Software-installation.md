# Overview and software installation

## Overview

![pam robot](https://ei.is.tuebingen.mpg.de/uploads/publication/image/18667/2PAMcompressed.jpg)

PAM robot (pneumatic artificial muscle robot) is a four degrees of freedom robot. Most of the days, we have it learn how to play tennis table. But it could be used for other purposes, e.g. exploring the control of artificial muscles.

It is controlled via the value of pressures of its 8 artificial muscles. Each joint is connected to 2 artificial muscles, called agonist and antagonist. If the pressure of the agonist is higher than the pressure of the antagonist (i.e. the agonist is more contracted than the antagonist), the joint moves left. A control command consists of setting the pressure(s) of one (or more) muscle(s).

We developed some software allowing for the control of the robot (or a [mujoco](http://www.mujoco.org/) simulated version of it). The software allows to send commands related to the desired pressures to the robot, as well as accessing the current and past states of the robot. The software is written in C++ and has python wrappers (and has been tested only on ubuntu).

Once the software installed, the typical workflow starts with calling in a terminal:

```bash
o80_pam
# or o80_mujoco, for a mujoco simulated robot
```

The command above spawns a "backend" process which connects to the robot. This process reads continuously (i.e. at a frequency of 200Hz or more) the state of the robot and writes it in a shared memory. Also, it reads the shared memory for commands to apply to the robot. 

User may then use a python (or a c++) API for interacting with the shared memory, i.e. reading the state of the robot (written by the backend) or writing commands to it (which will then be read by the backend and applied to the robot).

There are quite a few types of commands that can be written in the shared memory. The system is based on [o80](https://intelligent-soft-robots.github.io/code_documentation/o80/docs/html/index.html), and it is advised to read o80's documentation before going further.

## Software installation 

Installing the software will results in:

- having some executables installed on your system (e.g. 'o80_pam' already mentioned above)
- having some python packages installed
- useful for advanced users: some c++ libraries installed

The executables will be used to start the backend connecting to the robot, while the python packages can be used for developers to create control scripts that send commands to the backend (via the shared memory) and/or read states of the robot (also via the shared memory).

### step 1: install ubuntu

The software is supported only Ubuntu 18.04. It is likely to work on slightly older and newer version, but this has not been properly tested.

To get all required dependencies, after installation of 18.04, clone the [ubuntu installation scripts](https://github.com/machines-in-motion/ubuntu_installation_scripts) repository and run the setup_ubuntu script:

```bash
git clone https://github.com/machines-in-motion/ubuntu_installation_scripts.git
cd ubuntu_installation_scripts/official
sudo ./setup_ubuntu install all
```
This will install various packages via pip, pip3 and aptitude (including ROS).

### step 2: install mujoco

- create a folder /opt/mpi-is (may require sudo rights)
- create a folder /opt/mujoco (also sudo)
- download [mujoco200 for linux](https://www.roboti.us/index.html) 
- unzip mujoco200 in /opt/mpi-is (should result in folder /opt/mpi-is/mujoco200_linux)
- copy the licence file mjkey.txt to /opt/mujoco/
- open the permissions of the /opt/mpi-is and /opt/mujoco folders:

```bash
cd /opt
sudo chown -R root:users ./mpi-is
sudo chown -R root:users ./mujoco
sudo chmod -R 777 ./mpi-is
sudo chmod -R 777 ./mujoco
```

### step 3: python dependencies

- call: ```pip3 install isr_meta```
- call: ```pip3 install colcon-common-extensions```

### step 4: clone the sources from git

The software requires more than one repository to execute. In these instructions we use the [treep](https://gitlab.is.tue.mpg.de/amd-clmc/treep) project manager to help with this.

#### requirements

- You must first register your ssh-key to github. See instructions [here](https://docs.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)

- treep is likely to be already installed on your machine. If not:

```bash
pip3 install treep
```

#### cloning using treep

```bash
mkdir Software
cd Software
# clone the treep configuration
git clone git@github.com:intelligent-soft-robots/treep_isr.git
# list the list of projects
treep --projects
# get information about the project "PAM"
treep --project PAM_MUJOCO
# cloning all the repos of the project "PAM"
treep --clone PAM_MUJOCO
# checking the workspace status
treep --status
```
#### compile using colcon

For these instructions to work, python3 needs to be the default python (either system-wide or using a virtual environment).
To check the default version of python, in a terminal:

```bash
python --version
```

If this output something like 3.X, all is good. Otherwise you may want to use a [virtual environment](https://realpython.com/python-virtual-environments-a-primer/).

We use colcon to compile the workspace. In a terminal

```bash
cd /path/to/Software/workspace
colcon build
```

If all goes smooth, compilation will run for a while and will result in the creation of an "install" folder.
This install folder can be "activated" by sourcing it, i.e. in a terminal:

```bash
cd /path/to/Software/workspace/install
source ./install/setup.bash
```
For the software to work, the install folder needs to be sourced in all new terminals. A convenient way of doing this is to update the file ~/.bashrc:

```bash
# add this to ~/.bashrc file
echo "sourcing workspace"
source /path/to/Software/workspace/install/setup.bash
```  
### step 5: check things are ok

In a python3 terminal:

```python
import o80
import o80_pam
import pam_mujoco
import context
```
You may also try in a terminal:

```bash
o80_mujoco
```
You may check the software is correctly installed (cf instructions for client installation above).

These pages will also help:

- overview of [cmake usage](https://github.com/machines-in-motion/machines-in-motion.github.io/wiki/use_cmake)
- overview of [superbuilds](https://github.com/machines-in-motion/machines-in-motion.github.io/wiki/super_build_and_cmake), such as colcon and ament
