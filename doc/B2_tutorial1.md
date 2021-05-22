# Tutorial 1: Commands

## Starting a Mujoco simulated robot

In a terminal, call:
```bash
pam_mujoco tutorials_1_to_3
```

this will start an instance of pam_mujoco in a new terminal.

This instance does not start a simulated robot yet, as it works for a client
process to configure it.

## Introduction to commands

You may now run tutorial_1.py

```bash
python3 ./tutorial_1.py
```

Here some comments regarding the source code similar of the one of tutorial 1.

# configuring pam_mujoco and getting an interface to it.
# More on handle somewhere below.
# In this specific case, this will configure pam_mujoco
# to start a pressure controlled robot
handle = get_handle()

# getting an o80 frontend to the pressured robot
# The frontend will allow to send pressures to the robot
# and/or read the robot's state
frontend = handle.frontends["robot"]

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


## Introduction to handles

The tutorial above started with:

```python
handle = get_handle()
```
The code for the *get_handle* function is similar to:

```python
def get_handle():
    mujoco_id = "tutorials_1_to_3"
    robot_segment_id = "robot"
    control = pam_mujoco.MujocoRobot.PRESSURE_CONTROL
    robot = pam_mujoco.MujocoRobot(robot_segment_id,
                                   control=control)
    graphics=True
    accelerated_time=False
    handle = pam_mujoco.MujocoHandle(mujoco_id,
                                     robot1=robot,
                                     graphics=graphics,
                                     accelerated_time=accelerated_time)
    return handle
```

The code above requested to create an handle to the *pam_mujoco* process running on the mujoco_id
"tutorials_1_3", and configuring it:

- to run a pressure controlled robot with segment_id "robot"
- to show mujoco graphics
- to run realtime (and not accelerated_time)

During the handle creation, the corresponding configuration is written in the shared memory, and
the waiting *pam_mujoco* instance uses it to start.

The handle provides access to the corresponding o80 robot frontend, which will allow to send
commands to the robot:

```python
frontend = handle.frontends["robot"]
# "robot" is the robot_segment_id as set in the handle
```
