# More info: Mirroring real robot


To get a MuJoCo simulation to mirror the real robot, first, start the real robot:

```bash
o80_pamy2
# or o80_pamy1
```

The ```o80_pamy1``` or ```o80_pamy2``` executables request you to enter a segment_id (```real_robot``` as default). Take note of it.

Alternatively, you may also start a mujoco simulated robot that uses pressure control, see for example the [three first tutorials](B1_tutorial0). In the terminal, take note of the frontend related to the robot control, e.g. ```my_robot``` in this output:

```bash
adding controller:
	robot: pressure control, segment_id: my_robot, configurations:
		controller: /opt/mpi-is/pam_interface/pam.json
		agnonist muscles: /opt/mpi-is/pam_models//hill.json
		antagonist muscles: /opt/mpi-is/pam_models//hill.json
```


Then, start an instance of pam_mujoco with mujoco_id "mirroring":

```bash
pam_mujoco mirroring
```

Finally, start:

```
pam_mirroring_real_robot
```

In the dialog, use the value ```mirroring``` for ```mujoco_id_mirroring```, and the segment_id you took note of for ```segment_id_real_robot```.







