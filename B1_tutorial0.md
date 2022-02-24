# Tutorial 0: How to run tutorial demos

Code for demos and tutorials can be found in the pam_demos [repository](https://github.com/intelligent-soft-robots/pam_demos).

The typical process to run a demo or a tutorial is:

1. Open the terminal (of your choice)
2. Use the ```pam_mujoco```-command with the corresponding "mujoco_id"
3. Run a Python-script with the desired (control) commands.

## Starting a demonstration or tutorial

First, a MuJoCo handle (in the following indicated by the mujoco_id) has to be specified. For each tutorial a tutorial-specific mujoco_id has been prepared and can be found in the corresponding Python-script. 

```bash
pam_mujoco mujoco_id
```

For example, for Tutorial 1:

```bash
pam_mujoco tutorials_1_to_3
```

This will spawn a xterminal. Alternatively, you may start:

```bash
pam_mujoco_no_xterms tutorials_1_to_3
```

which will start the simulation in the background of the current terminal.

You may then run the demo, for example:

```bash
python ./tutorial_1.py
# python should be of version 3.x
```

## Stopping a demonstration or tutorial

The MuJoCo simulation can be stopped. For stopping the simulation, you may simple close the terminal from which you started the xterminal-application. Alternatively, you may call:

```bash
pam_mujoco_stop tutorials_1_to_3
```

or:

```bash
pam_mujoco_stop_all
# will stop all running pam_mujoco
```

## Further remarks

* Note that you may run the demo several times without the need to restart pam_mujoco.
* The "mujoco_id" depends on the demo and is indicated in the source file of the demo or in the README-file. Further information regarding the mujoco_id can be found here: [MuJoCo handles and contacts](C1_handle).





