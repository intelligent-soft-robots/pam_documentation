
# Mujoco handle and contacts


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

Usage of pressure commands are shown in tutorials 1 to 3

#### Joint controlled

Usage of joint commands are shown in tutorials 4 to 7


## Items (balls, hit points, goals ...)

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
  - MujocoItem.NO_CONTROL: the item will be controlled exclusively by o80 and its frontend. If there is no active o80 command, the last command is continuously used
  - MujocoItem.COMMAND_ACTIVE_CONTROL: the item is controlled by a mix of o80 commands and mujoco's physics engine. If an o80 command is active, the item is controlled by it. If no command is active, the item is "controlled" by mujoco's physical engine (e.g. gravity).
- contact_type:
  - pam_mujoco.ContactTypes.no_contact (default): the item fly through the robots and the table
  - pam_mujoco.ContactTypes.racket1: the item is affected by contact with the racket of the first robot
  - pam_mujoco.ContactTypes.racket2: the item is affected by contact with the racket of the second robot
  - pam_mujoco.ContactTypes.table: the item is affected by contact with the table

Once an instance of MujocoItem has been instantiated, it can be added to the handle, for example:

```python3

ball1 = pam_mujoco.MujocoItem("ball1")
ball2 = pam_mujoco.MujocoItem("ball2")
handle = pam_mujoco.MujocoHandle(MUJOCO_ID,
                                 table=True,
                                 balls=(ball1,ball2))	
```

