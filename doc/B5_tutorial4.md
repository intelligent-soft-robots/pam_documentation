# Tutorial 4: join control, table, balls, etc

## Tutorial's demo

A running example can be found in the (pam_demos)[https://github.com/intelligent-soft-robots/pam_demos] repository. 

In a first terminal start the backend:

```python
python ./tutorial_4_backend.py
```
in a second terminal, run the frontend:

```python
python ./tutorial_4_frontend.py
```

## Mujoco model files

### Overview

When the o80_mujoco executable is called:

```bash
o80_mujoco
```
A mujoco simulated pam robot is started.
 Mujoco relies on a xml model file to simulate a robot. When o80_mujoco is called, such a model file is created in /tmp/o80_pam_robot/o80_pam_robot.xml and mujoco loads it.

Generation of the xml model is based on template files. You can see these templates [here](https://github.com/intelligent-soft-robots/pam_mujoco/tree/master/models). In the o80_mujoco (python) [source](https://github.com/intelligent-soft-robots/pam_mujoco/blob/master/bin/o80_mujoco), there is this line:

```python
pam_mujoco.model_factory(model_name,robot1=True)
# model_name is an arbitrary string
```

This line triggers the generation of a mujoco model xml file corresponding only to a robot, and this is indeed what o80_mujoco spawn.

Alternatively, the function "model_factory" can be called with other arguments. For example: 

```python
pam_mujoco.model_factory(model_name,robot1=True,nb_balls=2)
```

The line above will result in the generation of a xml file corresponding to a robot, plus 2 balls.

### Model factory

The API of model factory is:

```python
import pam_mujoco
items = pam_mujoco.model_factory(model_name, # arbitrary string
                                 time_step = 0.002,
                                 table=False,nb_balls=1,
                                 robot1=False,robot1_position=[0.1,0.0,-0.44],
                                 robot2=False,robot2_position=[1.6,3.4,-0.44],
                                 robot2_orientation = [-1,0,0,0,-1,0],
                                 goal=False,hit_point=False,
                                 ball_colors=None,
                                 muscles=True)
```

Call to model_factory results in the generation of an Mujoco xml model file. The absolute path to this file is accessible:

```python
path = items["path"]
```

You may all model_factory with arguments to add ball(s), a goal mark, a hit_point mark, a table or a second robot (goal and hit_point are simple visual markers). You may also request the robot not to have any muscle actuation.

For example, the following script will start the simulation of 2 robots, a table, 3 balls and a goal:

```python
import pam_mujoco

model_name = "tutorial_model"
mujoco_id = "tutorial_mujoco_id"

# generation of a mujoco model xml file
# corresponding to a table, 3 balls, 2 robots
# and a goal (a goal is a simple visual marker)
items = pam_mujoco.model_factory(model_name,
                                 table=True,nb_balls=3,
                                 robot1=True,robot2=True,
                                 goal=True)

# some config for mujoco
config = pam_mujoco.MujocoConfig()
config.graphics = True # set to False if you do not need graphics
config.realtime = True # set to False if you prefer accelerated time

# starting the mujoco simulation
pam_mujoco.init_mujoco(config)
pam_mujoco.execute(mujoco_id,items["path"])
```

The simulation will run forever (or until the corresponding terminal is closed). It is possible to stop it by calling (in another script):

```python
import pam_mujoco
# we are using the same mujoco id as the one used to start the simulation
mujoco_id = "tutorial_mujoco_id"
pam_mujoco.request_stop(mujoco_id)
```

## Interacting with objects 

### Interacting with a ball

The script above started a simulation containing 3 simulated balls. These balls are subject to the (simulated) gravity, and will just fall forever. Not very exciting.

o80 can be used to interact the simulated balls, e.g. forcing the position/velocity of the balls and/or getting information about the balls.

To request the addition of a corresponding o80 backend to the simulation process, the script has to be updated:

 ```python

# the mujoco xml model generated including 3 balls
items = pam_mujoco.model_factory(model_name,
                                 table=True,nb_balls=3,
                                 robot1=True,robot2=True,
                                 goal=True)

# getting informations about the 3 generated balls
balls = items["ball"]

config = pam_mujoco.MujocoConfig()
config.graphics = True
config.realtime = True

pam_mujoco.init_mujoco(config)

# adding a o80 backend to send command 
# (and receiving information) to (from) the
# first ball
pam_mujoco.add_o80_ball_control("ball0",balls[0])

# starting the mujoco simulation. The o80 backend
# will listen to commands and write info about the ball
pam_mujoco.execute(mujoco_id,items["path"])
```

The method "add_o80_for_ball" reads "add an o80 backend to the Mujoco simulation". Consequently, the ball is no longer subject to gravity but gets fully controlled based on user commands: one interact with the first ball via o80 frontend instantiated in another script (or another process in the same script):

```python
import pam_mujoco
#  note: "ball0": argument passed to "add_o80_for_ball" in the previous script
frontend_ball = o80_pam.BallFrontEnd("ball0") 

# getting the information about the ball
ball = frontend_ball.latest()
position = ball.get_position()
velocity = ball.get_velocity()

# forcing position and velocity to the ball:
target_position = [1,1,1]
target_velocity = [0,0,0]
frontend_ball = add_command(target_position,target_velocity,o80.Mode.QUEUE)
frontend_ball.pulse()
```

The script above will move the ball to [1,1,1]

Something similar can be done for the other balls, or the goal (replace "Ball" with "Goal", e.g. add_o80_for_goal).

### Detecting contact

As presented above, this allows control of a simulated ball:

```python
pam_mujoco.add_o80_ball_control("ball0",
                                balls[0])
```

This ball may enter in contact with the table and/or the racket of the robot(s). It is possible to retrieve related information.

First, in the same way that a o80 backend was added to the mujoco simulation via the method "add_o80_ball_control", contact controllers have to be added to the mujoco simulation:

```python
ball = items["ball"][0]
table = items["table"]
robot = items["robot"]
# adding controller for monitoring contact between
# the racket of the robot and the ball
# ("contact_robot_ball" is an arbitrary id for this contact)
pam_mujoco.add_robot1_contact("contact_robot_ball",ball,robot)
# same, but for contact with the table
pam_mujoco.add_table_contact("contact_table_ball",ball,table)
```
Once the simulation started, corresponding information can be requested in another script via:

```python
import pam_mujoco
# note the contact id is the same as above
contact = pam_mujoco.get_contact("contact_table_ball") 
```
contact is the instance of a class providing the public attributes:

```python
# True if a contact ever occurred
contact.contact_occurred
# position (x y z) of the first contact (if any)
contact.position
# time stamp (int, nanoseconds) of the first contact (if any)
contact.time_stamp
# minimal distance between ball and table,
# useful in case no contact ever occurred
contact.minimal_distance
```
A limitation is that information about only the first contact is stored (i.e. not the history of contacts).

You may reset the contact information in order to start monitoring new contact:

```python
pam_mujoco.reset_contact("contact_table_ball")
```

### Playing a recorded ball trajectory

We recorded trajectories of real ball being launched and bouncing on a table tennis table. A python API allows to query these trajectories.
For example:

```python
import context
index,trajectory_points = list(context.BallTrajectories().random_trajectory())
```
This returns an index and a list of trajectory points.

The index allows to retrieve the name of the file in which the returned trajectory has been stored:

```python
file_name = context.BallTrajectories().get_file_name(index)
```

You may find the file in the folder /opt/mpi-is/context/trajectories/.

```trajectory_points``` is a list of trajectory points providing a position and velocity attributes:

```python
position = trajectory_points[0].position # x,y,z
velocity = trajectory_points[0].velocity # x,y,z
``` 
You may also retrieve a trajectory via an index:

```python
trajectory_points = list(context.BallTrajectories().get_trajectory(index))
```

To know which index correspond to which file:

```python
# prints list of files and related indexes.
# you may call this in a python terminal
import context
context.BallTrajectories().print_index_files()
```

You may use an o80 ball frontend to replay a ball trajectory in mujoco, for example:

```python
frontend_ball = o80_pam.BallFrontEnd("ball0")
_,trajectory_points = list(context.BallTrajectories().random_trajectory())
duration_s = 0.01
duration = o80.Duration_us.milliseconds(int(duration_s*1000))
total_duration = duration_s * len(trajectory_points)
for traj_point in trajectory_points:
    frontend_ball.add_command(traj_point,position,traj_point.velocity,
                               duration,o80.Mode.QUEUE)
frontend_ball.pulse()
```


### Hybrid: controlling a ball until contact

It is possible to use an o80 frontend to control a ball, but letting Mujoco's physic engine taking over once a contact occured.

Above, the function "add_o80_ball_control" was introduced. It was used to set an o80 backend for ball control in the mujoco simulation.

An alternative method is: "add_o80_ball_control_until_contact".

For example:

```python
ball = items["ball"][0]
table = items["table"]
pam_mujoco.add_table_contact("table",ball,table)
pam_mujoco.add_o80_ball_control_until_contact("ball","table",ball)
```
The above will also add a o80 backend for ball control to the mujoco simulation. Similarly as when "add_o80_ball_control" was used (and with the exact same API), it is possible to control the ball's position and velocity. But as soon as a contact is detected between the table and the ball, o80's command will be ignored, and the ball with be from that time managed by Mujoco's physic engine. 

Once the contact is reset:

```
pam_mujoco.reset_contact("table")
```

## Goal, HitPoint

Goal and HitPoint are visual markers. They can also be added to the mujoco's model, for example:

```python
items = pam_mujoco.model_factory(model_name,
                                 table=True,
                                 nb_balls=1,
                                 robot1=True,
                                 goal=True,
                                 hit_point=True)
goal = items["goal"]
hit_point = items["hit_point"]

# to allow frontend to control the goal                                                                                                                                                                                                                                                   
pam_mujoco.add_o80_goal_control("goal",goal)

# to allow frontend to control the hit point                                                                                                                                                                                                                                              
pam_mujoco.add_o80_hit_point_control("hit_point",hit_point)
```

They can be controlled similarly to balls, for example:

```python
hit_point = o80_pam.HitPointFrontEnd("hit_point")
goal = o80_pam.GoalFrontEnd("goal")

position = (1,1,1)
velocity = (0,0,0)
goal.add_command(position,velocity,o80.Mode.QUEUE)
goal.pulse()
```
 
## Joint Control

Mujoco simulated pam robot can be joint controlled (i.e. setting for each degree of freedom a desired joint angle and a desired angular velocity). 

For this, it is required to add a joint controller, for example:

```python
items = pam_mujoco.model_factory(model_name,
                                 table=True,
                                 nb_balls=2,
                                 robot1=True,
                                 goal=True,
                                 hit_point=True,
                                 ball_colors=((1,0,0,1),(0,0,1,1)))
robot = items["robot"]
pam_mujoco.add_o80_joint_control("robot",robot)
```
This allows to send robot control command via an o80 frontend, for example:

```python
robot = o80_pam.JointFrontEnd("robot")
joints = (math.pi/4.0,-math.pi/4.0,
          math.pi/4.0,-math.pi/4.0)
joint_velocities = (0,0,0,0)
duration = o80.Duration_us.seconds(2)
robot.add_command(joints,joint_velocities,duration,o80.Mode.QUEUE)
robot.pulse()
```
The frontend can also be used to query the robot state:

```
observation = robot.latest()
observation.get_positions()
observation.get_velocities()
```
