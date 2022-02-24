# More info: List of executables

Once the [installation](A1_overview_and_installation) procedure completed, various executables are installed.

## Dialog

Some executables trigger a dialog.
For example:

```bash
user@machine:~$ o80_dummy 


	0 | bursting_mode:	False
	1 | frequency:	500
	2 | nb_dofs:	4
	3 | pam_config_file:	/opt/mpi-is/pam_interface/pam.json
	4 | segment_id:	o80_pam_robot


		use these values ? ['y', index to change, 'h' for help]:
```

You may use the dialog to either accept the default configuration values, or to change them.

Note that alternatively, you may skip the dialog by configuring "manually" any of the configuration value, e.g.

```bash
o80_dummy -frequency 100 -pam_config_file /my/config/file.json
```

The above will start directly o80_dummy using the specified values (and the default values for the non specified arguments).

## o80_dummy

Starts a o80 backend connected to a "dummy" pressure controlled pam robot. No graphics, no realistic physics (at all). Used for debug and testing. See [tutorials 1 to 3](B2_tutorial1) for control.

## o80_real

Starts a o80 backend connected to a pressure controlled real robot (on robot computer only).
See also [tutorials 1 to 3](B2_tutorial1) for control examples.

## pam_mujoco

Spawn a new terminal that host a mujoco simulation with (pressure controlled or joint controlled) robot(s), ball(s), goal(s), etc.
See [tutorial 4](B5_tutorial4) for control example via a [handle](C1_handle).
Note that mujoco_id used as argument to *pam_mujoco* must match the mujoco_id passed as argument to the [handle](C1_handle).

For example:

```bash
pam_mujoco my_id
```

```python
handle = pam_mujoco.MujocoHandle("my_id")
```

It is possible to call *pam_mujoco* with several mujoco_ids:

```bash
pam_mujoco my_id1 my_id2 my_id3
```

in which case several (here 3) terminals will be spawned.

Note: *pam_mujoco* must be called *before* handle instantiation.

You may note that the process ids of the spawned processes are printed in the main terminal (in case you need to kill them for any reason).

## pam_mujoco_no_xterms

Similar to *pam_mujoco* (right above) with the difference that the MuJoCo simulation are not hosted by new terminals, but in the background of the current terminal.

## pam_mujoco_visualization

pam_mujoco_visualization takes 2 arguments:

```bash
pam_mujoco_visualization mujoco_id_from mujoco_id_to
```

It is expected that pam_mujoco_visualization is called *after*:

```bash
pam_mujoco mujoco_id_from
```

pam_mujoco will spawn a terminal hosting a pam_mujoco instance that will "mirror" the pam_mujoco instance running on mujoco_id "mujoco_id_from". Possibly useful if the pam_mujoco instance "mujoco_id_from" has been started without graphics, or has been started in burst mode (see [tutorial 6](B7_tutorial6)).

## pam_mujoco_stop

It takes a mujoco_id as argument, and kills the corresponding pam_mujoco instance (if any)

## pam_mujoco_stop_all

Kills all running instances of pam_mujoco

## o80_plotting

Starts a live plot of a pressure controlled robot. It shows the measured pressures, the desired pressure and the frequency of backend.
Works for pressure controlled robots started with o80_dummy, o80_real or pam_mujoco.

## o80_console

Starts to live print information about a pressure robot in the console. Indicate the current pressures, the desired pressures and joint angles. Works for pressure controlled robots started with o80_dummy, o80_real or pam_mujoco.

*Known bug* : will crash if the terminal is not broad enough.

## o80_introspection

Debug tool for o80. It will display live the status of all command exchange between the frontend and the backend of a o80 system running on the provided segment_id.

## o80_logger

Starts a process that will collect data regarding a pressure controlled robot. See [tutorial 5](B6_tutorial5)

## pam_server

pam_server is a low level interface to either a dummy or the real pam robot. See [here](C2_real_robot) for more information.

## pam_check

Started after pam_server, will increase then decrease the pressure of each muscles. See [here](C2_real_robot) for more information.

## o80_check

Similar to pam_check, but to be started after o80_real, o80_dummy or pam_mujoco (if simulating a pressure controlled robot)

## o80_swing_demo

Has a pressure robot executing a series of swing motions, to be started after o80_real, o80_dummy or pam_mujoco (if simulating a pressure controlled robot)

### pam_mirroring_real_robot

see this [page](C4_mirroring).
