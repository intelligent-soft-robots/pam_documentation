# UNDER CONSTRUCTION

## Reading robot data

Once a robot backend started, for example:

```bash
o80_mujoco
```

it starts dumping at each of its iteration in a rotating shared memory an instance of Observation. Observation is a class encapsulating information about the robot.

It is possible to use a frontend to read these instances via Python:

```python
import o80_pam
frontend = o80_pam.FrontEnd("o80_pam_robot")
observation = frontend.latest()
```
observation is an instance of Observation. It contains has the following method:

```python
# at each backend iteration (i.e. control iteration of o80_mujoco), an observation is generated.                  
# this gives the backend iteration number at which this observation was generated.                                                        
print("iteration",observation.get_iteration())

# the time stamp at which the observation was generated.                                                                                    
# it is an integer representing time in nano seconds                                                                                        
print("timestamp",observation.get_time_stamp())

# the pressure of the muscles as measured by sensors                                                                                        
print("observed pressures",observation.get_observed_pressures())

# the pressure of the muscles as the commands requested them to be.                                                                         
# Difference with observed pressures comes from either imprecision                                                                          
# and/or time for the system to reach the commanded pressures                                                                               
print("desired pressures",observation.get_desired_pressures())

# as measured by the encoders, in radian                                                                                                    
print("positions",observation.get_positions())

# finite difference applied on positions, in radian per seconds                                                                             
print("velocities",observation.get_velocities())

# on the real robot, encoders do not read a proper value until                                                                              
# the joint moved through a certain reference position. If ref_found                                                                        
# is False for a given join, it means the join did not yet go through this                                                                  
# position, and the values of positions and velocities (as above) are meaningless                                                           
print("references found",observation.get_references_found())

# the measured frequency of the backend at the time the observation was created.                                                            
frequency = observation.get_frequency()
```
You may get a history of observations:

```python
observations = frontend.get_latest_observations(10)
for observation in observations:
    print(observation,"\n")
```

Only a certain number of iteration are kept in memory:

```python
# requesting the last 10 millions observations. The rotating memory does not keep so many observations.                                     
# so instead, it will return all contained informations.                                                                                    
# to increase the memory size, the code needs to be recompiled after the "QUEUE_SIZE" (see o80_pam/srcpy/wrappers.cpp)                      
# is increased.                                                                                                                             
# note the reading and deserializing of so many observations from the shared memory takes some time                                         
observations = frontend.get_latest_observations(10000000)
print("number of observations read: {}".format(len(observations)))
print("spanning a duration of: {} seconds".format((observations[-1].get_time_stamp()-observations[0].get_time_stamp())*1e-9))
```
It is possible to request the observation corresponding to a specific backend iteration.

```python
latest_iteration = frontend.latest().get_iteration()
observation = frontend.read(latest_iteration-10)
print("requested observation of iteration {}, received observation of iteration {}".format(latest_iteration-10,observation.get_iteration()))
```
You can also make sure you read all observations generated during a time window:

```python
# getting latest observation and its iteration number                                                                                       
observation = frontend.latest()
tagged_iteration = observation.get_iteration()
# waiting                                                                                                                                   
time.sleep(3)
# getting all new observations generated since                                                                                              
observations = frontend.get_observations_since(tagged_iteration)
print("tagged iteration: {}".format(tagged_iteration))
print("recovered observations from {} to {}".format(observations[0].get_iteration(),
                                                    observations[-1].get_iteration()))
print("spanning a duration of: {} seconds".format((observations[-1].get_time_stamp()-observations[0].get_time_stamp())*1e-9))
```
You may also force your python code to run at the frequency of the backend by waiting for new observations:

```python
# you can wait for a new observation to be written by the frontend                                                                          
time_start = time.time()
# this is important to call this function before calling "wait_for_next" as below                                                           
frontend.reset_next_index()
observations = []
# this loop should run at the same frequency as the backend                                                                                 
while time.time()-time_start < 3:
    observations.append(frontend.wait_for_next())
# checking the frequency                                                                                                                    
duration = observations[-1].get_time_stamp() - observations[0].get_time_stamp()
frequency = (len(observations) / (duration*1e-9) )
print("collected {} observations at a frequency of {} hz".format(len(observations),frequency))
```
The *pulse* and *pulse_and_wait* presented previously and used then for sending commands, also return instances of Observation:

```python
frontend.add_command([0]*4,[0]*4,
                     o80.Duration_us.seconds(2),
                     o80.Mode.OVERWRITE)
# pulse both sends the queue of commands and                                                                                                
# returns the latest observations                                                                                                           
observation = frontend.pulse()

# waiting for the previous command to finish                                                                                                
time.sleep(2)
# getting latest observation                                                                                                                
observation1 = frontend.latest()
frontend.add_command([0]*4,[0]*4,
                     o80.Duration_us.seconds(2),
                     o80.Mode.QUEUE)
# pulse_and_wait returns the observation                                                                                                    
# generated at the iteration the command was finished                                                                                       
observation2 = frontend.pulse_and_wait()
duration = observation2.get_time_stamp()-observation1.get_time_stamp()
duration = float(duration)*1e-9
print("the command took around {} seconds to complete".format(duration))
```
