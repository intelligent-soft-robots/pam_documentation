# More info: Saving ball trajectories

It is possible to save in files both the position and orientation as observed 
by [tennicam_client](C5_visual_ball_tracking) and the state of the real robot
as observed by [o80_real](C2_real_robot). These files can be then replayed in a pam_mujoco
simulation. This simulation will replay both the ball as observed (red ball) and as subject to 
our [custom contact model](B5_tutorial4) (green ball). This is useful to assess the quality of the contact model.

## How-to

### Log files

Starting:

- tennicam and tennicam_client must be [running](C5_visual_ball_tracking)
- o80_real must be [running](C2_real_robot)

To start logging, in a terminal:

```
o80_robot_ball_logger
```

The dialog will propose to save the data into file that does not exist already.

### Replay

In a first terminal:

```
pam_mujoco robot_ball_replay
```

and in a second terminal:

```
o80_robot_ball_replay
```

### Parsing files in Python

The package o80_pam provides a parser for the saved files:

```python
import pathlib
import o80_pam
filepath = pathlib.Path("/path/to/the/file")
data = list(o80_pam.robot_ball_parser.parse(filepath))
```

each line in data is of format:

```python
( (ball_id,ball_time_stamp,ball_position,ball_velocity),
  (robot_time_stamp,robot_positions,robot_velocities) ) 
```


