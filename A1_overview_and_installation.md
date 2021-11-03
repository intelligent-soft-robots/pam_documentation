# Overview and software installation

## Overview

![pam robot](https://ei.is.tuebingen.mpg.de/uploads/publication/image/18667/2PAMcompressed.jpg)

PAM robot (pneumatic artificial muscle robot) is a four degrees of freedom robot. Most of the days, we have it learn how to play tennis table. But it could be used for other purposes, e.g. exploring the control of artificial muscles.

It is controlled via the value of pressures of its 8 artificial muscles. Each joint is connected to 2 artificial muscles, called agonist and antagonist. If the pressure of the agonist is higher than the pressure of the antagonist (i.e. the agonist is more contracted than the antagonist), the joint moves left. A control command consists of setting the pressure(s) of one (or more) muscle(s).

We developed some software allowing for the control of the robot (or a [mujoco](http://www.mujoco.org/) simulated version of it). The software allows to send commands related to the desired pressures to the robot, as well as accessing the current and past states of the robot. The software is written in C++ and has python wrappers (and has been tested only on ubuntu).

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

User may then use a python (or a c++) API for interacting with the shared memory, i.e. reading the state of the robot (written by the backend) or writing commands to it (which will then be read by the backend and applied to the robot).

There are quite a few types of commands that can be written in the shared memory. The system is based on o80, and it is advised to read o80's [documentation](http://people.tuebingen.mpg.de/mpi-is-software/o80/docs/o80/index.html) before going further.

## Software installation 

Installing the software will results in:

- having some executables installed on your system (e.g. 'o80_pam' or 'pam_mujoco' already mentioned above)
 
- having some python packages installed
 
- useful for advanced users: some c++ libraries installed

The executables will be used to start the backend connecting to the robot, while the python packages can be used for developers to create control scripts that send commands to the backend (via the shared memory) and/or read states of the robot (also via the shared memory).

Note that you need a valid [mujoco key](https://www.roboti.us/license.html) to use the mujoco simulated robot.  

### From tar archives

The below will:

- install mujoco in /usr/local/
 
- create configuration files in /opt/mpi-is
 
- install (c++) libraries and python packages

#### binaries

pam software's binaries are available only for ubuntu18.04/python3.6 and ubuntu20.04/python3.8.

To install, first select a version by visiting : [http://people.tuebingen.mpg.de/mpi-is-software/pam/latest/](http://people.tuebingen.mpg.de/mpi-is-software/pam/latest/) or [http://people.tuebingen.mpg.de/mpi-is-software/pam/older/](http://people.tuebingen.mpg.de/mpi-is-software/pam/older/). Then, for example (update with your selected version):

```bash
wget http://people.tuebingen.mpg.de/mpi-is-software/pam/latest/pam_ubuntu20.04_py3.8_1.0.tar.gz
tar -zxvf ./pam_ubuntu20.04_py3.8_1.0.tar.gz
sudo ./apt-dependencies
sudo ./pip3-dependencies
sudo ./create_config_dirs
sudo ./install_mujoco
./configure
sudo make install # note: 'make install' is directly called, no previous call to 'make'
sudo ldconfig
```

#### sources

```bash
wget http://people.tuebingen.mpg.de/mpi-is-software/pam/latest/pam_source.tar.gz
tar -zxvf ./pam_source.tar.gz
sudo ./apt-dependencies
sudo ./pip3-dependencies
sudo ./create_config_dirs
sudo ./install_mujoco
./configure
make
sudo make install
sudo ldconfig
```

#### mujoco key

Copy your mujoco key (mjkey.txt) in /opt/mujoco.


(install_via_colcon)=

### Via colcon workspace

This is the recommanded way for developpers of the PAM software (as opposed to the users of it).

[Colcon](https://colcon.readthedocs.io/en/released/) is the built system of [ROS2](https://docs.ros.org/en/foxy/index.html).
The instructions below will result in the setup of a colcon workspace. Possibly, if you would like to use o80 in a ROS2 project, you may copy the cloned packages to an existing workspace.

#### Adding your ssh key to github

See: [github documentation](https://help.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh).

All the following instructions assume your ssh key has been activated, i.e.:

```bash
# replace id_rsa by your key file name
ssh-add ~/.ssh/id_rsa
```

- You must first register your ssh-key to github. See instructions [here](https://docs.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)

- treep is likely to be already installed on your machine. If not:
```bash
pip install treep
```

#### Dependencies and configuration folder

in a terminal:

```bash
mkdir /tmp/pam && cd /tmp/pam
wget http://people.tuebingen.mpg.de/mpi-is-software/pam/resources/apt-dependencies
wget http://people.tuebingen.mpg.de/mpi-is-software/pam/resources/create_config_dirs
wget http://people.tuebingen.mpg.de/mpi-is-software/pam/resources/install_mujoco
wget http://people.tuebingen.mpg.de/mpi-is-software/pam/resources/pip3-dependencies
sudo ./apt-dependencies
sudo ./create_config_dirs
sudo ./install_mujoco
sudo ./pip3-dependencies
```

#### mujoco key

Copy your mujoco key (mjkey.txt) in /opt/mujoco.

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
colcon build --cmake-args ' -DCMAKE_BUILD_TYPE=Release '
```

This will result in a "install" folder containing the compiled binaries

### Activating the workspace

In each new terminal, the workspace needs to be sourced:

```bash
source /path/to/Software/install/setup.bash
```

Possibly, you may want to add the line above to the ~/.bashrc file (so that each new terminal source the workspace automatically).


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
