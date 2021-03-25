## Introduction

In tutorial 1, we covered duration, speed and direct commands. This tutorial introduce the iteration command.

"Iteration" refers to the backend, i.e. the control iteration of the robot. At each control iteration, the backend reads the commands queue, compute the desired pressure to apply to the robot, applies it to the robot, read the current state of the robot from sensors and write a corresponding Observation in the shared memory.

After starting a simulated robot:

```bash
o80_mujoco
```
you may start a console:

```bash
o80_console
```
This allows you to see the increasing control iteration count.

Iteration commands allows to specify using a python frontend the value of the desired pressure for upcoming iteration numbers.

## Getting the current iteration number

After starting the simulated robot (*o80_mujoco*):

```python
import time
import o80
import o80_pam

frontend = o80_pam.FrontEnd("o80_pam_robot")
# newest iteration
iteration = frontend.latest().get_iteration()
```

## waiting for an iteration

In tutorial 2, the *read* method of the frontend was used to access from the shared memory an observation corresponding to a past iteration.
The same method can be used to wait for an upcoming iteration:

```python
iteration = frontend.latest().get_iteration()
future_iteration = iteration+5000
# will wait until the backend reaches this iteration number
observation = frontend.read(future_iteration)
reached_iteration = observation.get_iteration() # will be equal to future_iteration
```

## example

```python
frontend = o80_pam.FrontEnd("o80_pam_robot")


start_iteration = frontend.latest().get_iteration()

pressure1 = 20000
target_iteration1 = start_iteration+3000
frontend.add_command([pressure1]*4,[pressure1]*4,
                     o80.Iteration(target_iteration1),
                     o80.Mode.QUEUE)

pressure2 = 0
target_iteration2 = start_iteration+6000
frontend.add_command([pressure2]*4,[pressure2]*4,
                     o80.Iteration(target_iteration2),
                     o80.Mode.QUEUE)

pressure3 = 20000
target_iteration3 = start_iteration+9000
frontend.add_command([pressure3]*4,[pressure3]*4,
                     o80.Iteration(target_iteration3),
                     o80.Mode.QUEUE)

print("sending commands")
frontend.pulse()

print("waiting for iteration: {}".format(target_iteration1))
observation = frontend.read(target_iteration1)
print("reached iteration: {}".format(observation.get_iteration()))

print("waiting for iteration: {}".format(target_iteration2))
observation = frontend.read(target_iteration2)
print("reached iteration: {}".format(observation.get_iteration()))

print("waiting for iteration: {}".format(target_iteration3))
observation = frontend.read(target_iteration3)
print("reached iteration: {}".format(observation.get_iteration()))
```

In this example, the desired pressure values that should be applied at exact backend iteration numbers are specified from the frontend.

## synchronizing the frontend and the backend

This example of usage is a bit evolved:


```python
pressure = 10000
target_iteration = frontend.latest().get_iteration()+5
backend_frequency = frontend.latest().get_frequency()
time_start = time.time()
print("running frontend at 1/5th of backend frequency ({} Hz)".format(backend_frequency/5.0))
# running 500 frontend control iteration
for _ in range(500):
    previous_iteration = target_iteration
    # control value that must be reached at the 
    # end of the *next* frontend control iteration
    target_iteration += 5
    pressure+=20
    frontend.add_command([pressure]*4,[pressure]*4,
                         o80.Iteration(target_iteration),
                         o80.Mode.QUEUE)
    frontend.pulse()
    frontend.read(previous_iteration)
time_end = time.time()
print("frequency: {} Hz".format(500.0/(time_end-time_start)))
```
 
During the time the backend applies a command, the frontend computes the control value that should be applied at the next frontend control loop. This has the frontend running at a frequency enforced by the backend. This is important because the frontend is not realtime safe (because python is not realtime), while the backend may be.


## relative iteration

So far, all iteration number were *absolute*, i.e. iteration numbers as counted since the start of the backend.

It is possible to use relative iteration number, i.e. the iteration number as counted from a later time.

The o80 class Iteration takes two extra boolean arguments:

- relative: if True (False is the default), it corresponds to a relative iteration number
- reset: if True (False is the default), a command using this instance of Iteration reset the iteration counter.

Example:

```python
# this corresponds to 1000 iterations counting                                                                                                                                                                                                                                            
# from the moment the command is started                                                                                                                                                                                                                                                  
relative=True
reset=True
iteration = o80.Iteration(1000,relative,reset)
pressure=0
# i.e. reaching pressure 0 in 1000 iteration                                                                                                                                                                                                                                              
frontend.add_command([pressure]*4,[pressure]*4,
                     iteration,
                     o80.Mode.QUEUE)
obs1 = frontend.pulse_and_wait()
# this corresponds to iteration number 2000                                                                                                                                                                                                                                               
# counting from relative iteration number at                                                                                                                                                                                                                                              
# which the previous command was started.                                                                                                                                                                                                                                                 
relative=True
reset=False
iteration = o80.Iteration(2000,relative,reset)
pressure=16000
# i.e. reaching pressure 16000 in 1000 iterations                                                                                                                                                                                                                                         
# (previous command took 1000 iterations, and this                                                                                                                                                                                                                                        
#  want to reach a relative iteration number 2000)                                                                                                                                                                                                                                        
frontend.add_command([pressure]*4,[pressure]*4,
                     iteration,
                     o80.Mode.QUEUE)
obs2 = frontend.pulse_and_wait()
print("number of iterations of second commands: "
      "{}".format(obs2.get_iteration()-obs1.get_iteration()))
```






