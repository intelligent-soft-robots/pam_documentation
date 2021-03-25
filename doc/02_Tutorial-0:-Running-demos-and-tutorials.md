Code for demos and tutorials can be found in the pam_demos [repository](https://github.com/intelligent-soft-robots/pam_demos).

## Most demos

The typical process to run a demo or a tutorial is:

in a first terminal, start o80_mujoco:

```bash
o80_mujoco
```
Optionally, in two other terminals you can start the console and the plot:

```bash
o80_plotting
```

```bash
o80_console
```

Note: when o80_mujoco is closed, o80_console and o80_plotting must be restarted.

All the above can be started with the default configuration.

In a last terminal, start the frontend, for example:

```bash
cd /path/to/pam_demos
python tutorial_1.py
# tutorial_1.py can be run several times without the need to restart o80_mujoco
```

## Specialized backend demos

Some demos/tutorials do not use the backend instantiated by "o80_mujoco". Rather, that use a specialized backend. 
These demos are splitted in two files: something_backend.py and something_frontend.py.

In these cases, the procedure to run is, for example:

```bash
cd /path/to/pam_demos
python tutorial_4_backend.py
```
and in another terminal:

```bash
cd /path/to/pam_demos
python tutorial_4_frontend.py
# tutorial_4_frontend can be run several times without restarting tutorial_4_backend.py
```

## Bursting mode demos

Some demos are named something_bursting.py.

In this case, o80_mujoco must be started in "bursting mode":

```bash
o80_mujoco --bursting_mode
```

then the demo can be executed, e.g:

```bash
cd /path/to/pam_demos
python tutorial_6_bursting.py
```






