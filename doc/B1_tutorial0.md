# Tutorial 0: How to run tutorial demos

Code for demos and tutorials can be found in the pam_demos [repository](https://github.com/intelligent-soft-robots/pam_demos).

The typical process to run a demo or a tutorial is:

In a terminal, start pam_mujoco, with the correct mujoco_id:

```bash
pam_mujoco mujoco_id
```

The "mujoco_id" to use depends on the demo, and is indicated in the source file of the demo, or in the readme. For example, for tutorial 1:

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

Note that you may run the demo several times without the need to restart pam_mujoco.

The mujoco simulation can be stopped.

If you started with a x-terminal, you may simply close the terminal. Alternatively, you may call:

```bash
pam_mujoco_stop tutorials_1_to_3
```

or:

```bash
pam_mujoco_stop_all
# will stop all running pam_mujoco
```






