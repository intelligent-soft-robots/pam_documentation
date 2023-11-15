# More info: Saving states to file

## How-to

When creating a mujoco handle, one can pass values to the arguments ```save_data``` and ```save_folder```,
for example:

```python

mujoco_id = "myapp"
robot_segment_id = "robot"
control = pam_mujoco.MujocoRobot.PRESSURE_CONTROL
robot = pam_mujoco.MujocoRobot(robot_segment_id,
                              control=control)
graphics=True
accelerated_time=False
save_data = True      # !
save_folder = "/tmp/" # !
handle = pam_mujoco.MujocoHandle(mujoco_id,
                                 robot1=robot,
                                 graphics=graphics,
                                 accelerated_time=accelerated_time,
				 save_data=save_data,
				 save_folder=save_folder)
```


Consequently, the related instance of pam_mujoco will run a driver which dumps the robot state
in a csv file located in the ```/tmp``` folder. The name of the file will also contain the mujoco_id
and the time of its creation.

To see an example of the parsing for such a file, see ```/pam_mujoco/bin/pam_mujoco_compare.py```


## Limitations

If two robots are running, only the state of one will be saved in the file.


## Under the hood

Setting the ```save_data``` argument to True will result in an instance of ```MujocoStatePrinterController``` being added to pam_mujoco. At each mujoco iteration this controller reads the values of the current mujoco "mjModel" and write the corresponding values to the file. The time stamp correspond to the computer time stamp (not the mujoco simulation time stamp). See ```/pam_mujoco/include/pam_mujoco/mujoco_state.hpp```.
