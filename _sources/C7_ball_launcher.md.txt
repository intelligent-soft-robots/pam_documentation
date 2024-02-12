# More info: Ball launcher

The robot laboratory has a ball launcher that can be activated programmatically.

## How-to

### Start the ball launcher

The ball launcher is connected to a multiple socker power supply. Turn it on. The raspberry pi attached to the launcher should start and display something like:

```
-----------------------------------
| Welcome to ball launcher beepy  |
-----------------------------------

to ssh to me: user pi, password: ---

- sourcing colcon workspace
- killing already running server
- starting the ball launcher server on IP 10.42.--.-- and PORT 5555
```

Take note of the IP address.

### Launch a ball (from terminal)

In a terminal:

```
launch_ball
``` 

This will start a dialog, which one completed will have a ball launched.


### Launch a ball (from python script)

``` python
import time

from ball_launcher_beepy import BallLauncherClient

# Enter the correct IP here
ip = "10.42.XX.XX"
port = 5555

phi = 0.5
theta = 0.5
motor_top_left = motor_top_right = motor_bottom = 0.4

client = BallLauncherClient(ip, port)
client.set_state(phi, theta, motor_top_left, motor_top_right, motor_bottom)
time.sleep(2)
client.launch_ball()
time.sleep(2)
```

All arguments are floats between 0 and 1 (except of ip which is string and port which is an int)

- ip, port : of the server (installed on the ball launcher Rasperri Pi)
- phi : azimutal angle of the launch pad
- theta : altitute angle of the launch pad
- top_left_motor: activation of the top left motor
- top_right_motor: activation of the top right motor
- bottom_motor: activation of the bottom motor

## Installation of the server

On the Raspberry Pi of the ball launcher, install:

- pip3 install: pyparsing==2.0.2, colcon-common-extensions, empy, catkin-pkg, sphinx, breathe, xinabox-OC05, xinabox-OC03
- apt: protobuf-compiler, libprotobuf-dev, libzmq3-dev

In a folder ```/home/pi/Workspaces/ball_launcher/workspace/src``` (git) clone:

- https://github.com/ament/ament_cmake (branch eloquent)
- https://github.com/ament/ament_package (branch eloquent)
- https://github.com/intelligent-soft-robots/ball_launcher_beepy.git
- git@github.com:machines-in-motion/mpi_cmake_modules.git

Then call ```colcon build``` from the folder ```/home/pi/Workspaces/ball_launcher/workspace```.

Copy paste the content of this [file](https://github.com/intelligent-soft-robots/ball_launcher_beepy/blob/master/misc/server_message.bash) at the end of the file ```/home/pi/.bashrc```.

