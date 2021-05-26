
# More info: Mujoco handle and contacts


In the tutorials, handles are used to configure the mujoco simulation spawed by *pam_mujoco*. The handles are also used to interface with the simulated robots, balls and other items.

This page provides a more complete documentation over handles.


The signature of the constructor is:

```python
import pam_mujoco

handle = pam_mujoco.MujocoHandle(mujoco_id:str,
                                 burst_mode: bool=False,
                                 accelerated_time:bool=False,
                                 graphics:bool=True,
                                 time_step: float = 0.002,
                                 table: bool = False,
                                 robot1: MujocoRobot = None,
                                 robot2: MujocoRobot = None,
                                 balls: list=[],
                                 goals: list=[],
                                 hit_points: list=[],
                                 read_only: bool=False)
```


## Robot(s)

### MujocoRobot

Currently, up to 2 robots can added to pam_mujoco.
Robots are added by passing instances of *MujocoRobot* to the handle constructor.

The signature of a MujocoRobot is:

```python

robot = pam_mujoco.MujocoRobot(segment_id,
                               position=[0.1,0.0,-0.44],
                               orientation=None,
                               control=NO_CONTROL,
                               active_only_control=CONSTANT_CONTROL,
                               json_control_path=pam_interface.DefaultConfiguration.get_path(),
                               json_ago_hill_path=pam_models.get_default_config_path(),
                               json_antago_hill_path=pam_models.get_default_config_path())
```

- segment_id is an arbitrary user string, that will be used to query the frontend to the robot
- position is the 3d position of the robot
- orientation is the xyaxes of the robot as required by mujoco (see mujoco [documentation](http://www.mujoco.org/book/modeling.html#COrientation))
- control may take the values:
  - MujocoRobot.NO_CONTROL: no interface to the robot
  - MujocoRobot.JOINT_CONTROL: the robot can be controlled via commands providing desired joint position (in radian) or angular velocity (radian per second). Note that this is not a control per se. This only means the joint's positions and angular velocities are overwritten by the command's values. Such commands are obviously only available on mujoco simulated robots (and not on the real robot) 
  - MujocoRobot.PRESSURE_CONTROL: the robot can be controlled via pressure commands
- active_control_only:
  - Mujoco.CONSTANT_CONTROL: the robot will be controlled exclusively by o80 and its frontend. If there is no active o80 command, the robot keep replaying the last command
  - Mujoco.COMMAND_ACTIVE_CONTROL: the robot is controlled by a mix of o80 commands and mujoco's physics engine. If an o80 command is active, the robot is controlled by it. If no command is active, the robot is "controlled" by mujoco's physical engine (e.g. gravity). This has effect only on joint controlled robot (and not on pressure controlled robot)
- json_control_path: for pressure controlled robot, path to the control configuration json file which specifies for example the minimal and maximal pressures that can be applied on each muscles (see ```/opt/mpi-is/ for default configuration files)
- json_ago/antago_hill_path: for pressure controlled robot, path to the configuration of the muscles


### Interfacing with robots

#### Pressure controlled

Usage of pressure commands are shown in [tutorials 1 to 3](B2_tutorial1.html)

#### Joint controlled

Usage of joint commands are shown in [tutorials 4 to 7](B5_tutorial4.html)


## Items and contacts (balls, hit points, goals ...)

An undefinite numbers of items can be added to the mujoco simulation, the limit being the capacities of the computer you run the simulation on.

Ball are physicals object with a small weight, while hit points and goals are only graphical markers.

Balls, hit points and goals are added similarly.

### MujocoItem

To add an item, the first step is to create an instance of MujocoItem:

```python
item = pam_mujoco.MujocoItem(segment_id,
                             color=None,
			     control=False,
			     contact_type=None)

```

- segment_id is an arbitrary string, that will be used to query the related frontend
- color: list of 4 float values between 0 and 1, RGB + alpha channel
- control:
  - MujocoItem.NO_CONTROL: no active control (only mujoco physic engine)
  - MujocoItem.CONSTANT_CONTROL: the item will be controlled exclusively by o80 and its frontend. If there is no active o80 command, the last command is continuously used
  - MujocoItem.COMMAND_ACTIVE_CONTROL: the item is controlled by a mix of o80 commands and mujoco's physics engine. If an o80 command is active, the item is controlled by it. If no command is active, the item is "controlled" by mujoco's physical engine (e.g. gravity).
- contact_type:
  - pam_mujoco.ContactTypes.no_contact (default): the item fly through the robots and the table
  - pam_mujoco.ContactTypes.racket1: the item is affected by contact with the racket of the first robot
  - pam_mujoco.ContactTypes.racket2: the item is affected by contact with the racket of the second robot
  - pam_mujoco.ContactTypes.table: the item is affected by contact with the table

Once an instance of MujocoItem has been instantiated, it can be added to the handle, for example:

```python

ball1 = pam_mujoco.MujocoItem("ball1")
ball2 = pam_mujoco.MujocoItem("ball2")
handle = pam_mujoco.MujocoHandle(MUJOCO_ID,
                                 table=True,
                                 balls=(ball1,ball2))	
```

The handle makes then the o80 frontend to the item control available:

```python
frontend = handle.frontends["ball1"]
```

See for example [tutorial 4](B5_tutorial4.html).

### Contacts

#### Contacts and handle

If contacts has been activated for an item, the handle provides method to query them:

```python
ball = pam_mujoco.MujocoItem("ball",contact_type=pam_mujoco.ContactTypes.table)
handle = pam_mujoco.MujocoHandle(mujoco_id,table=True,balls=(ball,))
contact_information = handle.get_contact("ball")
```

"contact_information" is an instance of context.ContactInformation, which has the attributes:

- contact_occured: true if there has been at least one contact, false otherwise
- position: the 3d position of the first contact, if any (irrelevant data otherwise)
- time_stamp: time stamp (in mujoco time) of the first contact, if any (irrelevant data otherwise)
- minimal_distance: minimal distance between the item and the contactee (table or racket) if no contact occured (irrelevant data otherwise)

Important to note:

- get_contact only returns information regarding the *first* contact
- once a first contact occurs, the o80 control of the item get *disabled* (i.e. commands added via the frontend will be ignored), i.e. the item motion is "controlled" only by the mujoco physical engine. 

The above may seem peculiar, but matches our need related to have a robot learning to play table tennis using [HYSR](https://arxiv.org/abs/2006.05935): we command a tennis table ball (using o80) to "play" a prerecorded trajectory until contact with the robot's racket.

The fact that only the first contact is recorded and that the item control get disabled is an obvious limitation, but the contact can be reset (i.e. contact_occured is set to false, minimal_distance is set to None, and o80 control is restarted):

```python
handle.reset_contact("ball")
```

It is also possible to deactivate the contact:

```python
handle.deactivate_contact("ball")
```

For example, after the above the ball would go through the table rather than bouncing on it.
The contact can be reactivated:

```python
handle.activate_contact("ball")
```

#### Customized contacts

A side note: for modeling the contact, we override Mujoco's engine to apply a custom contact model, see this [file](https://github.com/intelligent-soft-robots/pam_mujoco/blob/master/include/pam_mujoco/recompute_state_after_contact.hpp).


