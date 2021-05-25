# Executables: the list

Once the installation procedure completed, various executables are installed.

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

Starts a o80 backend connected to a "dummy" pam robot. No graphics, no realistic physics (at all). Used for debug and testing.

## o80_real

Starts a o80 backend connected to a pressure controlled real robot (on robot computer only)

## pam_mujoco

 - o80_dummy: 
 - o80_real: 
 - pam_mujoco: spawn terminal(s) hosting a mujoco simulated robot(s) and possibly some items (balls, goals, etc). See the tutorials for more information.
 - pam_mu
 - o80_console: provides runtime information about the state of the real or mujoco simulated robot (if pressure controlled). 
 - o80_plot: provides a runtime plot of the measured and desired pressures of the robot, as well as the frequency of the backend. Has to be started after o80_real, o80_mujoco or o80 dummy.
 - o80_introspection: provides 