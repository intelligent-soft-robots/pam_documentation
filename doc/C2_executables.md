# Executables: the list

Once the installation procedure completed, these executables should be installed and in the path:

 - o80_dummy: starts a o80 backend connected to a "dummy" pam robot. No graphics, no realistic physics (at all). Used for debug and testing.
 - o80_mujoco: starts a o80 backend connected to a mujoco simulated, and pressure controlled, pam robot
 - o80_real: starts a o80 backend connected to a pressure controlled real robot (on robot computer only)
 - o80_console: provides runtime information about the state of the real or mujoco simulated robot. Has to be started after o80_real, o80_mujoco or o80 dummy.
 - o80_plot: provides a runtime plot of the measured and desired pressures of the robot, as well as the frequency of the backend. Has to be started after o80_real, o80_mujoco or o80 dummy.
 - o80_introspection: provides 