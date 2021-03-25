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
For an exhaustive guide on the Observation class and methods of the frontend available to read observations from the shared memory, visit this demo:

[reading_observations_demo.py](https://github.com/intelligent-soft-robots/o80_pam/blob/master/demos/reading_observations_demo.py)

 


