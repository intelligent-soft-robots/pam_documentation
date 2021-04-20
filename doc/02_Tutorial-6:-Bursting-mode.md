## Introduction

In the previous tutorial, we started the robot backend via:

```bash
o80_mujoco
```

This triggers the simulation of a pam robot with control running at a predefined frequency. This can be seen via:

```bash
o80_console
```

It is possible to start the robot back using the "bursting mode" via:

```bash
o80_mujoco --bursting_mode
# or alternatively:
# o80_mujoco
# and using the dialog to turn on the bursting mode
```
(note: It may be that a window appears, but the robot can not be seen and a message "Simulate is not responding" is shown. This is ok for now)

If after starting the backend using the starting mode you start the console:

```bash
o80_console
```
you may see that a very low frequency is shown, and the iteration number does not increase. 

This is because in bursting mode, the robot control iterates only when being asked to do so by a frontend.

For example, in a python terminal:

```python
import o80
import o80_pam

# creating a frontend
segment_id = "o80_pam_robot"
frontend = o80_pam.FrontEnd(segment_id)

# adding a command:
# setting all pressures to 12000                                                                                                                  
start_iteration = frontend.latest().get_iteration()
frontend.add_command([12000]*4,[12000]*4,
                     o80.Iteration(start_iteration+1000),
                     o80.Mode.OVERWRITE)
frontend.pulse()

# requesting the backend to execute 1000 iterations
frontend.burst(1000)
```

When running the code, it may be seen that the iteration numbers increases to 1000, and then stop increasing again. This is because the frontend requested the backend to execute 1000 iterations only (burst function).

## Example

Here is a full running example:

```python
import time
import math
import o80
import o80_pam


# default id when starting pam_robot executable                                                                                             
segment_id = "o80_pam_robot"
frontend = o80_pam.FrontEnd(segment_id)


# starting at low pressure                                                                                                                  
start_iteration = frontend.latest().get_iteration()
frontend.add_command([12000]*4,[12000]*4,
                     o80.Iteration(start_iteration+1000),
                     o80.Mode.OVERWRITE)
frontend.burst(2000)


start_iteration = frontend.latest().get_iteration()
low_pressure = 12000
high_pressure = 20000
nb_iterations = 1000

# requesting to go to high, low and again high pressures                                                                                    
frontend.add_command([high_pressure]*4,[high_pressure]*4,
                     o80.Iteration(start_iteration+nb_iterations),
                     o80.Mode.OVERWRITE)
frontend.add_command([low_pressure]*4,[low_pressure]*4,
                     o80.Iteration(start_iteration+2*nb_iterations),
                     o80.Mode.QUEUE)
frontend.add_command([high_pressure]*4,[high_pressure]*4,
                     o80.Iteration(start_iteration+3*nb_iterations),
                     o80.Mode.QUEUE)
frontend.pulse()


# playing the sequence by "jumps" of 2000 iterations                                                                                        
total_to_play = 3*nb_iterations
total_played = 0
jump = 500
while total_played<total_to_play:
    print("\nJump ...")
    frontend.burst(jump)
    total_played+=jump
    print("...wait")
    time.sleep(1.0)
```

## Bursting on real robot

When the mujoco simulated robot is started in bursting mode, the whole simulation is stopped when the backend waits for bursting signals from the frontend (i.e. the mujoco's virtual time also stops).

But the real robot can also be started in bursting mode:

```
o80_real --bursting_mode
```

In this case, while the lower level pressure controllers keep running at high frequency, the higher level control will iterate only upon burst signals. In other hand, the values of the desired pressure will be updated only upon reception of burst signals, but the efforts of the lower level control to have the values of the real pressures of the muscles converged toward the desired pressure will not stop.

## Master frequency

We saw in a previous tutorial (tutorial 3) that when the bursting mode is *not* used, it is possible to have the frontend frequency matching the backend frequency, for example:

```python
# backend NOT running in bursting mode
while True:
   target_iteration += 1
   frontend.add_command([pressure]*4,[pressure]*4,
                        o80.Iteration(target_iteration),
                        o80.Mode.QUEUE)
   frontend.pulse()
   frontend.read(target_iteration)
```

The loop above should run at the frequency of the backend.

On the other hand, the bursting mode can be used to have the backend running at a frequency set by the backend.
For example:

```python
# backend running in bursting mode
while True:
   frontend.add_command([pressure]*4,[pressure]*4,
                        o80.Mode.QUEUE)
   frontend.pulse()
   frontend.burst()
```

the above will have the backend running at the frequency set by this while loop.

## Bursting with table, ball, etc

Tutorial showed how to add table, balls, goals and hit points to the mujoco model, and how these items could be controlled via o80 frontends.

The code below shows how to start mujoco with items in bursting mode:

```python
File Edit Options Buffers Tools Python Help                                                                                                                                                                                                                                               
import pam_mujoco
import o80_pam

model_name = "pam_tutorial_6"
mujoco_id = "tutorial_6_mujoco_id"

items = pam_mujoco.model_factory(model_name,
                                 table=True,robot1=True,
                                 muscles=False)

ball = items["ball"]
robot = items["robot"]

mconfig = pam_mujoco.MujocoConfig()
mconfig.graphics = True
mconfig.realtime = True

pam_mujoco.init_mujoco(mconfig)

pam_mujoco.add_o80_ball_control("ball",ball)
pam_mujoco.add_o80_joint_control("robot",robot)

# setting bursting mode !                                                                                                                                                                                                                                                                 
pam_mujoco.add_bursting(mujoco_id,"robot")

model_path = pam_mujoco.paths.get_model_path(model_name)
pam_mujoco.execute(mujoco_id,model_path)
```

This code is similar to the one shown in tutorial 4, except that a "burster" was added to the robot.

Consequently, the "burst" method of the robot frontend can be called to have the mujoco simulation iterating, for example:

```python
File Edit Options Buffers Tools Python Help                                                                                                                                                                                                                                               
import math
import time
import o80
import o80_pam
import pam_mujoco
import context

ball = o80_pam.BallFrontEnd("ball")
robot = o80_pam.JointFrontEnd("robot")


# target position of ball                                                                                                                                                                                                                                                                 
position1 = (0.5,3,1)
position2 = (1.5,3,1)
velocity = (0,0,0)

# target position of robot                                                                                                                                                                                                                                                                
joints = (math.pi/4.0,-math.pi/4.0,
          math.pi/4.0,-math.pi/4.0)
joint_velocities = (0,0,0,0)

nb_iterations = 3000
current_iteration = robot.latest().get_iteration()
iteration = o80.Iteration(current_iteration+nb_iterations)

ball.add_command(position1,velocity,iteration,o80.Mode.QUEUE)
robot.add_command(joints,joint_velocities,iteration,o80.Mode.QUEUE)

ball.pulse()
robot.pulse()

per_step = 500
nb_steps = int(nb_iterations/per_step)

# between "bursts", the simulation pause
for _ in range(nb_steps):
    print("step !")
    robot.burst(per_step)
    time.sleep(2)
``` 

 





