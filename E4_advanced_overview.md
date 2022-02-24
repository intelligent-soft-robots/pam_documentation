# Developer's guide 4: Advanced overview

This page is a good read for anybody who would like to have a better understanding on how the software works "under the hood".


## MuJoCo model XML file

For Mujoco to work,  model xml file that describes the robot and environment is needed.
Possibly, this xml file can be created "by hand".
In the case of pam_mujoco, things are a bit more involved because the API let the user customize the environment, e.g. add more balls, add a target, add muscles, etc. (see [handle](C1_handle)). For achieving this, the xml file is created "on the fly" by python in order to match the user configuration. The code for doing this is here:

- https://github.com/intelligent-soft-robots/pam_mujoco/blob/master/python/pam_mujoco/models.py

If an example of an xml file is needed, one may run for example:

https://github.com/intelligent-soft-robots/pam_demos/blob/main/tutorial_4_backend.py#L57

which will generate one in a folder of /tmp/

## MuJoCo controller

A controller is a piece of software that is called at each iteration of mujoco, and can modify mujoco's global variables.
Mujoco has a global variable "mjcb_control" which is a pointer to a controller function. The user can set this pointer to the function of its choice, and this function will be called at each iteration.
The signature of the function must be :

```c++
void function_name(const mjModel* m, const mjData* d)". 
```
The function takes effect by overwriting some values in m and d.

In the pam mujoco code, we do this at this line:

- https://github.com/intelligent-soft-robots/pam_mujoco/blob/master/src/run_mujoco.cpp#L174

The function give can be simple, but in our case it is bit complex. The function we pass is not a controller, but a series of controllers that will be called in succession (e.g. one for controlling ball1, another for controlling the pressures, etc).
The user can add controllers by calling the functions here (functions add_xxx): 

- https://github.com/intelligent-soft-robots/pam_mujoco/blob/master/include/pam_mujoco/run_mujoco.hpp 

These functions add controllers to this vector: 

- https://github.com/intelligent-soft-robots/pam_mujoco/blob/master/include/pam_mujoco/controllers.hpp#L50

and the "apply" function (that will be called at each iteration) simply call each controller one by one:

- https://github.com/intelligent-soft-robots/pam_mujoco/blob/master/src/controllers.cpp#L52

The controllers for the robots are :

### MirrorRobot (poor naming, it just means "position and velocity control of the robot")

- https://github.com/intelligent-soft-robots/pam_mujoco/blob/master/include/pam_mujoco/mirror_robot.hpp
- https://github.com/intelligent-soft-robots/pam_mujoco/blob/master/include/pam_mujoco/mirror_robot.hxx

### PressureController

- https://github.com/intelligent-soft-robots/pam_mujoco/blob/master/include/pam_mujoco/pressure_controller.hpp
- https://github.com/intelligent-soft-robots/pam_mujoco/blob/master/include/pam_mujoco/pressure_controller.hxx


## Relation between the model xml file and the controllers

To "items" in the xml files correspond indexes in the mjModel* that is passed to the controller function.
Let's take MirrorRobot as example.
This controller takes in its constructor a string "robot_joint_base":

- https://github.com/intelligent-soft-robots/pam_mujoco/blob/master/include/pam_mujoco/mirror_robot.hxx#L6

This string correspond to the name of the first joint in the xml model file.
We use mujoco functions to get corresponding indexes:

- https://github.com/intelligent-soft-robots/pam_mujoco/blob/master/include/pam_mujoco/mirror_robot.hxx#L43

These indexes allows us to overwrite values in mujoco datas. For example here we overwrite the position values of the joints:

- https://github.com/intelligent-soft-robots/pam_mujoco/blob/master/include/pam_mujoco/mirror_robot.hxx#L84

## Relation between o80 and controllers

The above explains how we can overwrite mujoco values with values of our choice. Here we will see how we get the values "of our choice".
MirrorRobot encapsulates an instance of o80 backend:

- https://github.com/intelligent-soft-robots/pam_mujoco/blob/master/include/pam_mujoco/mirror_robot.hxx#L8

This backend's job is to provide desired values for each iteration, via its "pulse" function:

- https://github.com/intelligent-soft-robots/pam_mujoco/blob/master/include/pam_mujoco/mirror_robot.hxx#L61

The pipeline during runtime is:

A o80 frontend is used by the user to set desired values via commands (add_command and pulse functions), as for example here:

- https://github.com/intelligent-soft-robots/pam_demos/blob/main/tutorial_4_frontend.py#L33

which results in desired values here (same link as above):

- https://github.com/intelligent-soft-robots/pam_mujoco/blob/master/include/pam_mujoco/mirror_robot.hxx#L61

## Putting things together

Hopefully the above will clarify what happens in this file:

- https://github.com/intelligent-soft-robots/pam_demos/blob/main/tutorials/tutorial_4.py

Here:

- https://github.com/intelligent-soft-robots/pam_demos/blob/main/tutorials/tutorial_4.py#27

the xml file is generated and the controllers are added.

## C++ and Python

In the above, some code is in C++, so other code is in Python.
It works because Python encapsulate the C++ code, here:

- https://github.com/intelligent-soft-robots/pam_mujoco/blob/master/srcpy/wrappers.cpp

