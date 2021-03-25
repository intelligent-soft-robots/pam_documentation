# UNDER CONSTRUCTION !
# Tutorial

## Starting a Mujoco simulated robot

In a terminal, call:
```bash
o80_mujoco
# answer 'y' to the question 'use these values'
```
This starts a mujoco process that simulates a PAM robot. 

Optionally, in another terminal, you may call:

```bash
o80_console
```

This will print realtime information about the state of the robot.

Also optionally, in another terminal, you may call:

```bash
o80_plotting
```

which will print a live plot. The first 4 plots are for each degrees of freedom (red: pressure as measured by sensors, green: desired pressure as set by controllers, violet: angle of the joint, mapped from [-pi,pi] to [0,max pressure]). The last plot shows the frequency at which the robot controller runs.

*** 
**How o80_console and o80_plotting work**
In case you are curious: the process o80_mujoco writes at each control iteration the state of the robot into a shared memory. o80_console and o80_plotting are simple python script which at each iteration read this shared memory and display the corresponding state of the robot, one in the terminal, the other in a live plot. 
***


## Introduction to commands

In another terminal, start a python or ipython terminal

```bash
ipython
``` 

In this python terminal, call :

```python
import time
import math
import o80
import o80_pam

# connecting to the shared memory of the robot's controller
frontend = o80_pam.FrontEnd("o80_pam_robot")

pressure = 20000
duration = 5 # seconds
# creating a command locally. The command is *not* sent to the robot yet.
frontend.add_command([pressure]*4,[pressure]*4,
                     o80.Duration_us.seconds(duration),
                     o80.Mode.QUEUE)

# sending the command to the robot, and waiting for its completion.
frontend.pulse_and_wait()

```
You should observe the pressures of all muscles raising to 20000 in 5 seconds.

Note that you can add more than one command at once:

```python
# adding a first command 
pressure = 12000
duration = 3 # seconds
frontend.add_command([pressure]*4,[pressure]*4,
                     o80.Duration_us.seconds(duration),
                     o80.Mode.QUEUE)

# adding a second command
pressure = 20000
frontend.add_command([pressure]*4,[pressure]*4,
                     o80.Duration_us.seconds(duration),
                     o80.Mode.QUEUE)


# sending both commands to the robot, and waiting for their completions.
print("sending commands to shared memory and waiting for completion ...")
frontend.pulse_and_wait()
print("... completed !")
```
In the program above, the method "pulse_and_wait" returns once both commands have been executed by the robot. 

```python
pressure = 15000
duration=10
frontend.add_command([pressure]*4,[pressure]*4,
                     o80.Duration_us.seconds(duration),
                     o80.Mode.QUEUE)
pressure = 20000
frontend.add_command([pressure]*4,[pressure]*4,
                     o80.Duration_us.seconds(duration),
                     o80.Mode.QUEUE)
# sending command to the robot, and returning immediately
frontend.pulse()
```
Above, we use the method "pulse" instead of "pulse_and_wait". You may notice that the method returns immediately. "pulse" writes the command in the shared memory, and the robot executes it. But as the robot does this, you may create new commands.

For example, rerun the code above, and immediately execute:

```python
pressure = 0
duration = 1
frontend.add_command([pressure]*4,[pressure]*4,
                     o80.Duration_us.seconds(duration),
                     o80.Mode.QUEUE)
frontend.pulse()
```

You may notice that the pressures of the muscles go to 15000, then 20000, and finally to 0 (or their minimal pressure value). While the robot was running the commands for setting the pressures to 15000 and 20000, it receives the supplementary command to set the pressures to 0. The mode *o80.Mode.QUEUE* commanded the command to go to pressure 0 to start only once the other commands have been achieved. On the contrary, if we had run:

```python
pressure = 0
duration = 1
frontend.add_command([pressure]*4,[pressure]*4,
                     o80.Duration_us.seconds(duration),
                     o80.Mode.OVERWRITE)
frontend.pulse()
```
the mode *o80.Mode.OVERWRITE* has the command to go to pressure 0 replacing the previous command. Similarly:

```python
pressure = 12000
duration = 10
frontend.add_command([pressure]*4,[pressure]*4,
                     o80.Duration_us.seconds(duration),
                     o80.Mode.QUEUE)
frontend.pulse()
time.sleep(5)
pressure = 0
duration = 1
frontend.add_command([pressure]*4,[pressure]*4,
                     o80.Duration_us.seconds(duration),
                     o80.Mode.OVERWRITE)
frontend.pulse()
```

the code above has the robot starting to go toward the pressures 12000, but after 5 seconds this is interrupted (*o80.Mode.OVERWRITE* used) and the pressures brutally (in 1 second) go to 0.

## add_command overloads

### controlling only selected muscle(s)

All the commands applied so far targeted all muscles. It is possible to request the change of the pressure of only one muscle:

```python
muscle=0
frontend.add_command(muscle,12000,o80.Duration_us.seconds(3),o80.Mode.OVERWRITE)
frontend.pulse()
```
The above will request a change in the pressure of the muscle indexed 0.

```python
frontend.add_command(0,15000,o80.Duration_us.seconds(3),o80.Mode.OVERWRITE)
frontend.add_command(1,20000,o80.Duration_us.seconds(6),o80.Mode.OVERWRITE)
frontend.pulse()
```
Note that the command above will have the muscles 0 and 1 changing pressure at the same time. Because these two commands target 2 different muscles, the second command does not overwrite the first one.

### controlling a degree of freedom

```python
dof=0
frontend.add_command(dof,20000,15000,o80.Duration_us.seconds(3),o80.Mode.OVERWRITE)
frontend.pulse()
```
The command above will have the pressures of the agonist and antagonist muscles of the degree of freedom indexed 0 reach the values 20000 and 15000 (respectively) in 3 seconds. 


### controlling all muscles

```python
agonists = [15000,16000,17000,18000]
antagonists = [18000,17000,16000,15000]
frontend.add_command(agonists,antagonists,o80.Duration_us.seconds(3),o80.Mode.OVERWRITE)
frontend.pulse()
```
This command will target all muscles, for example the target pressure values for the first degree of freedom will be (15000,18000).

### speed commands

All the commands so far have been *duration* command, i.e. the request to interpolate between the current desired pressure value to a target desired pressure value over a given duration. It is possible to also create speed command, i.e. requesting the desired pressures to achieve a target value at a certain velocity (in terms of unit of pressure per unit of time).

Here are examples of speed commands:
  
```python
agonists = [15000,16000,17000,18000]
antagonists = [18000,17000,16000,15000]
frontend.add_command(dof,20000,15000,o80.Speed.per_second(300),o80.Mode.OVERWRITE)
dof=0
frontend.add_command(dof,20000,15000,o80.Speed.per_second(200),o80.Mode.QUEUE)
frontend.add_command(3,15000,o80.Speed.per_second(400),o80.Mode.OVERWRITE)
frontend.add_command(4,20000,o80.Speed.per_second(300),o80.Mode.OVERWRITE)
frontend.pulse()
```
### direct commands

It is possible to create commands that do not specify any duration or speed. Direct commands request the desired pressure to reach the target pressure as fast as possible. For example:

```python
# creating a sinusoid trajectory
pressure = 15000                                                                                                                                                                                            
v = 0.                                                                                                                                                                                                      
increment = 0.025                                                                                                                                                                                           
amplitude = 3000 
dof=2                                                                                                                                                                                           
for _ in range(5000):                                                                                                                                                                                        
    v+=increment                                                                                                                                                                                            
    ago = pressure + int(amplitude*math.sin(v))                                                                                                                                                             
    antago = pressure - int(amplitude*math.sin(v))                                                                                                                                                          
    frontend.add_command(dof,                                                                                                                                                                           
                         ago,antago,                                                                                                                                                                    
                         o80.Mode.QUEUE)                                                                                                                                                                
# playing the trajectory                                                                                                                                                                               
frontend.pulse_and_wait()                                                                                                                                                                                   
```
Similarly to duration and speed commands, direct commands may use o80.Mode.QUEUE or o80.Mode.OVERWRITE, and refers to specific muscles, degrees of freedom or full set of pressures

### Iteration command

Iteration command are an advanced type of command covered later in this tutorial.



### Iteration command




## API documentation 

The API documentation of all our software is [here](https://intelligent-soft-robots.github.io/).
It is automatically updated when new code is pushed to the master branches.

## Package overview 

The packages below host code for controlling the pneumatic artificial muscle (PAM) robot (the real robot, or a mujoco simulated robot). This control may be done in c++ or in python. 

![graph dependencies](https://intelligent-soft-robots.github.io/images/dependencies_graph.png)

Overview of all packages (bottom to top) : 

- [shared memory](https://github.com/machines-in-motion/shared_memory): package for (realtime) **interprocess sharing of data** via a shared memory. 
- [realtime tools](https://github.com/machines-in-motion/real_time_tools) : **realtime utilities**, e.g. spawning of realtime threads. 
- [time series](https://github.com/machines-in-motion/time_series) : data structure built over the shared memory package: **shared circular buffer** enhanced with synchronization tools (e.g. condition variables triggered when a new item is append to the buffer). 
- [synchronizer](https://github.com/intelligent-soft-robots/synchronizer): tool for **synchronizing processes**, with interoperability between c++ and python. E.g. a python process may be used to set the frequency of a c++ process.
- [o80](https://intelligent-soft-robots.github.io/code_documentation/o80/docs/html/index.html): **wrapper over time series and synchronizer**. The time series API is enriched with methods for **managing queues of commands** via python.
- [o80_example](https://intelligent-soft-robots.github.io/code_documentation/o80_example/docs/html/index.html) : canonical example / tutorial of o80
- [pam_interface](https://intelligent-soft-robots.github.io/code_documentation/pam_interface/docs/html/index.html): **low level code / drivers for connecting to the PAM robot**. See the [documentation](https://intelligent-soft-robots.github.io/code_documentation/pam_interface/docs/html/index.html) of this package to see basic usage of this robot. This packages also contains the code for starting a **dummy pam robot** (i.e. a robot with the same API as the real robot, for debugging purposes). 

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

This packages hosts these executables:

    - o80_dummy : starts a **control server** over a dummy pam robot
    - o80_real: starts a **control server** over the real robot
    - o80_plotting: **dynamic plotting** of the state of the robot
    - o80_console: terminal **dynamic display of the state of the robot**
    - o80_check: Commands are sent to each robot dof, one at a time. Useful to check if the robot has issues
    - o80_swing_demo : python demo of code sending commands to a robot. Has the robot performing swing motions
    - o80_pressure_demo : python demo of code sending pressure commands to the robot
    - o80_joint_control_demo : python demo on how to send **joint position commands** to the robot

- [pam_models](https://github.com/intelligent-soft-robots/pam_models): **artificial muscle models in c++** (currently only the hill model). 

Included configuration files (installed in /opt/mpi-is):

    - hill.json : all parameters of the model

- [context](https://github.com/intelligent-soft-robots/context): packages meant to host utility code useful to create environments. Currently, host the code for managing **pre-recorded (table tennis) ball trajectories** (in python, see ball_trajectories.py). The pre-recorded trajectories are installed in /opt/mpi-is/context

- [pam_mujoco](https://github.com/intelligent-soft-robots/pam_mujoco) : code for managing **simulated PAM robot(s) in the context of table tennis**. This package hosts the code for **generating mujoco models of robots, table and balls**, and starting a corresponding **mujoco simulations**. All items (robot, ball, etc) may be controlled via an **o80 python API**. 

The python packages hosts: 

    - models.py : the generate_model function allows to create customized mujoco model
    - start_mujoco.py: encapsulates code to start mujoco simulated robots, either pressure controlled or position controlled
    - mirroring.py : convenience code for sending "mirroring" commands from a pressure controlled simulated robot to a position controlled simulated robot (i.e. current joint positions and velocities of the pressure controlled robot are read and sent as command to the position controlled robot)

This package also hosts the executables:

     - o80_mujoco: starts a mujoco simulated robot (pressure control).
     - pam_mujoco : starts a mujoco simulated robot (position control), tennis table and ball
     - pam_visualization: visualization of pam_mujoco (useful if the latest has not been started with graphics)
     - pam_mirroring: if a o80 robot has been started (either o80_pam, o80_dummy or o80_mujoco), and a pam_mujoco has been started, has the pam_mujoco mirroring the o80 robot
     - pam_mujoco_start_mirrored_robots: starts o80_mujoco, pam_mujoco (accelerated and bursting mode) and pam_visualization
     - pam_mujoco_start_mirrored_robots_accelerated: starts o80_mujoco (accelerated), pam_mujoco (accelerated and bursting mode) and pam_visualization

 
