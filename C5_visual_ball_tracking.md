# More info: Visual ball tracking

```{note}
Page is only useful to persons having access to the robot lab in the Max Planck Institute for Intelligent Systems
```

## Operators

### Description

The robot lab is equipped with four RGB cameras, which can be used to track the (3D) position of a table tennis ball.
For the server, the software used for this is [tennicam](https://github.com/intelligent-soft-robots/tennicam) which has been developed internally by Sebastian Gomez-Gonzalez.
The desktop "rodau" is installed with the server software, and the cameras are plugged to it, ready to be used.
For the client, the software used is [tennicam_client](https://github.com/intelligent-soft-robots/tennicam_client),
which implements an {doc}`o80 <o80:index>` standalone. The client is install along the PAM software, as described [here](A1_overview_and_installation). 

### How-to

(start_tennicam)=

#### How to start the server?

- Turn on the "bright" light above the table tennis. 
- Login to rodau using the ball_tracking user. The password is written on the desktop.
- Open a terminal.
- Call `tennicam_start`. Two terminals should open. If they do not show any error message, the tracking is active.

#### How to fix the server?

If you experience any issue, you can try to run in a terminal:

- `tennicam_list_cameras`: check if the drivers detect the four cameras
- `tennicam_ping_cameras`: check if the desktop can ping the four cameras
- `tennicam_capture_indep`*: check if the desktop can use the drivers to capture pictures from the cameras
- `tennicam_capture`*: check if the desktop can use the drivers of the cameras to capture synchronized pictures

\* The "capture" commands only work if the tennicam tracker server (started by
  `tennicam_start`) is _not_ running.  If it is running, you need to stop it
  first.

#### How to start the client?

The client can be started on any Ubuntu desktop installed with the PAM software.
In a first terminal (you may use the default parameters):

```bash
tennicam_client
```

Optionally, if you want to see a log of the ball position as received from the server,
in another terminal:

```
tennicam_client_print
```

In your python code, you may then use an {doc}`o80 <o80:index>` frontend
to access ball informations.

```python
import tennicam_client

TENNICAM_CLIENT_DEFAULT_SEGMENT_ID = "tennicam_client"

frontend = tennicam_client.FrontEnd(TENNICAM_CLIENT_DEFAULT_SEGMENT_ID)
obs = frontend.latest()
ball = obs.get()
print(ball.to_string())

# other useful methods:
# position = obs.get_position()
# velocity = obs.get_velocity()
# iteration = obs.get_iteration()
# time_stamp = obs.get_time_stamp()
# ball_id = obs.get_ball_id()

```

For an example, see the source code of `tennicam_client_print` [here](https://github.com/intelligent-soft-robots/tennicam_client/blob/master/bin/tennicam_client_print).


(display_tennicam)=

#### How to display the tracked ball in MuJoCo?

In a terminal:

```bash
pam_mujoco tennicam_client_display
# or: pam_mujoco_no_xterms tennicam_client_display
```

and in another terminal:

```
tennicam_client_display
```

A MuJoCo simulation will start, displaying the ball.

:::{admonition} Vicon
To set table pose in the visualisation based on information provided by the
Vicon system, run `tennicam_client_display` with the ``--vicon`` flag. Note that
in this case ``vicon_o80_standalone`` needs to be run as well (see
{ref}`vicon`).
:::

To stop the mujoco simulation, type in any terminal `pam_mujoco_stop tennicam_client_display`.


(tennicam_client_config_transform)=

#### How to fix the transform of the ball?

The ball is detected in a given frame, and then its position goes through a transformation (translation and rotation).
The transformation applied is specified in the configuration file
`~/.mpi-is/pam/tennicam_client/config.toml` (or
`/opt/mpi-is/pam/tennicam_client/config.toml`)
which has, for example, the content:

```toml
[transform]
translation = [0.5, 0.5, 0]
# rotation is given as extrinsic xyz-Euler angles in radian
rotation = [0.2, 0, 0]
[server]
hostname = "rodau"
port = 7660
```

To update the parameters of the transform:

- when you start `tennicam_client`, use the dialog to set `active_transform` to `True`.
Note that this slow down the client, so set `active_transform` to `True` only when tuning the transform.

- start `tennicam_client_display` as described above.

- in yet another terminal, run:

```bash
tennicam_client_transform_update
```

which will start a dialog allow you to tune transform. The updated transform is applied to the active client, so
may see the result in the mujoco simulation popped up by `tennicam_client_display`.

The dialog allows you to save the transform in the configuration file (i.e. to overwrite the `config.toml`).
This ensure the next time `tennicam_client` is started (without `active_transform` set to `True`), the desired transform is applied. 

#### How to log ball information?

After starting `tennicam_client`, start in another terminal:

```bash
tennicam_client_logger
```
The dialog will propose to you to save data in an not-already-existing file. 
The dump of the data in the file starts as soon as the logger start.
ctrl+c to stop the logging.

Once ball information has been dumped into a file, it is possible to replay the recorded ball behavior into a mujoco simulation.

In a first terminal:

```bash
pam_mujoco tennicam_client_replay
```

In another terminal:

```bash
tennicam_client_replay
```

A dialog will allow you to enter the path to the file to replay.

To parse a dumped file, you may use the parser:

```python
import tennicam_client
for ball_info in tennicam_client.parse(path_to_file):
    ball_id,time_stamp,position,velocity = ball_info 
```

See the source code of [tennicam_client_replay](https://github.com/intelligent-soft-robots/tennicam_client/blob/master/bin/tennicam_client_replay.py) for an example.


## Installation of the server

In case the installation on rodau has been compromized, and you need to reinstall.

### Basics requirements

- Ubuntu 20.04
- you must be part of the Intelligent Soft Robots GitHub domain
- your SSH key must be set on GitHub

### Requirement: Cuda 10.0

If you are at MPI-IS, add to /etc/bash.bashrc:

```
echo "- setup CUDA 10.0 to /is/software/nvidia/cuda-10.0/lib64"
export LD_LIBRARY_PATH=/is/software/nvidia/cuda-10.0/lib64
export PATH=$PATH:/is/software/nvidia/cuda-10.0/bin
export CUDA_HOME=/is/software/nvidia/cuda-10.0
```

Then open a new terminal or source:

```
source /etc/bash.bashrc
```

Alternatively, to install Cuda:

```
sudo apt install -y cuda-libraries-dev-10-1 cuda-misc-headers-10-1 cuda-minimal-build-10-1
```

### Clone the treep project

Install tree:

```
pip3 install treep
```

and clone the treep configuration:

```bash
mkdir ~/Tennicam # or any other directory of your choice
cd ~/Tennicam
git clone git@github.com:intelligent-soft-robots/treep_isr.git
treep --clone BALL_TRACKING
```

### Install additional dependencies

```bash
cd ~/Tennicam/workspace/src/tennicam/
sudo ./install_dependencies
```

As, among other things, this compiles OpenCV, this runs for a while

### Compile

```bash
cd ~/Tennicam/workspace
colcon build
```

### Source the workspace

Add to ~/.bashrc:

```
echo "-sourcing tennicam"
source ~/Tennicam/workspace/setup.bash
```

and start a new terminal

### Global installation of configuration files

Tennicam requires some configuration file. To install them:

```
cd ~/Tennicam/workspace/src/tennicam/extras
sudo ./install_config
```


