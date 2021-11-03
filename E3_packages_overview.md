# Developer's guide 3: packages overview


The software for the control of the PAM robot (real or mujoco simulated) is splitted over several packages.
These packages are hosted either at the [github "Intelligent Soft Robots" organization](https://github.com/intelligent-soft-robots)
or at the [github "Machines in Motion Laboratory" organization](https://github.com/machines-in-motion).

If you installed the software via treep/colcon or via the source tar ball (as described [here](A1_overview_and_installation)), these package are also present on your machine.

Here a graph providing the dependencies between all the packages.

![graph dependencies](https://intelligent-soft-robots.github.io/images/dependencies_graph.png)

Overview of all packages (bottom to top) : 

- [shared memory](https://github.com/machines-in-motion/shared_memory): package for (realtime) **interprocess sharing of data** via a shared memory.

- [realtime tools](https://github.com/machines-in-motion/real_time_tools) : **realtime utilities**, e.g. spawning of realtime threads.

- [time series](https://github.com/machines-in-motion/time_series) : data structure built over the shared memory package: **shared circular buffer** enhanced with synchronization tools (e.g. condition variables triggered when a new item is append to the buffer).

- [synchronizer](https://github.com/intelligent-soft-robots/synchronizer): tool for **synchronizing processes**, with interoperability between c++ and python. E.g. a python process may be used to set the frequency of a c++ process.

- {doc}`o80 <o80:index>`: **wrapper over time series and synchronizer**. The time series API is enriched with methods for **managing queues of commands** via python.

- {doc}`o80_example <o80_example:index>`: canonical example / tutorial of o80

- [pam_interface](https://github.com/intelligent-soft-robots/pam_interface): **low level code / drivers for connecting to the PAM robot**. This packages also contains the code for starting a **dummy pam robot** (i.e. a robot with the same API as the real robot, for debugging purposes).

This package is host of the executables:

  - pam_server (python) : starts a server process for control of either the real or a dummy robot

  - pam_check (python): activates all dof of the robot one by one. Can also be used as an example on how to send/read command to pam_server

It is also the host of this configuration file (installed in /opt/mpi-is):

  - pam.json : for setting the minimum and maximum pressures to apply to the robot, as well as setting the server frequency

- [o80_pam](https://github.com/intelligent-soft-robots/o80_pam): **o80 API for control over the PAM robot**. While pam_server only allows for direct commands, o80_pam allows for sending queues of commands to the robot. 

It also comes with the following python modules:

  - o80_pressures : the class **o80Pressures** is a convenience class to send pressures commands to the robot (and reading state of the robot) via o80
  - o80_robot_mirroring : the class **o80RobotMirroring** is a convenience class to send desired position/velocity commands to the robot. Can be used only for the control of mujoco robots (see o80_mujoco package below)
  - o80_ball , o80_hit_point, o80_goal: the classes **o80Goal**, **o80Ball**, **o80HitPoint** are convenience classes to set position of ball/goal/hit points to mujoco robots
  - joint_position_controller: the class **JointPositionController** implements a PID controller that will compute the control pressures to apply to the robot to reach a desired robot joint posture (in terms of radians for each dof).

This package hosts these executables:

  - o80_dummy : starts a **control server** over a dummy pam robot
  - o80_real: starts a **control server** over the real robot
  - o80_plotting: **dynamic plotting** of the state of the robot
  - o80_console: terminal **dynamic display of the state of the robot**
  - o80_check: Commands are sent to each robot dof, one at a time. Useful to check if the robot has issues
  - o80_swing_demo : python demo of code sending commands to a robot. Has the robot performing swing motions

- [pam_models](https://github.com/intelligent-soft-robots/pam_models): **artificial muscle models in c++** (currently only the hill model). Included configuration files (installed in /opt/mpi-is):

  - hill.json : all parameters of the model
  
- [context](https://github.com/intelligent-soft-robots/context): packages meant to host utility code useful to create environments. Currently, host the code for managing **pre-recorded (table tennis) ball trajectories** (in python, see ball_trajectories.py). The pre-recorded trajectories are installed in /opt/mpi-is/context

- [pam_mujoco](https://github.com/intelligent-soft-robots/pam_mujoco) : code for managing **simulated PAM robot(s) in the context of table tennis**. This package hosts the code for **generating mujoco models of robots, table and balls**, and starting a corresponding **mujoco simulations**. All items (robot, ball, etc) may be controlled via an **o80 python API**. 
The python packages hosts: 

  - models.py : the generate_model function allows to create customized mujoco model
  - mujoco_handle.py : source code for the pam_mujoco handles

This package also hosts the executables:

  - pam_mujoco : starts a mujoco simulated robot(s)
  - pam_mujoco_no_xterms : starts a mujoco simulated robot(s)
  - pam_mujoco_stop : killing an instance of pam_mujoco
  - pam_mujoco_stop_all : killing all instances of pam_mujoco
  - pam_mujoco_visualization: visualization of pam_mujoco (useful if the latest has not been started with graphics)

 
- [pam_documentation](https://github.com/intelligent-soft-robots/pam_documentation): host of the documentation you are currently reading.
