# More info: Using the real robot

## Method 1: PAM interface

pam_interface provides a Python interface to the Pneumatic Artificial Muscle (PAM) developed at the Intelligent Soft Robots Laboratory (Empirical Inference Department, Max Planck Institute for Intelligent Systems).

![PAM_ROBOT](https://ei.is.tuebingen.mpg.de/uploads/publication/image/18667/2PAMcompressed.jpg)

### Robot overview

PAM is a robotic arm with 4 rotating joints. Each joint is controlled via 2 artificial muscles (agonist and antagonist muscle). Motion of the joint is obtained by tuning the pressure applied to these two muscles (i.e. applying contractions to the muscles). The robot is connected to a pressure source.

The control PC of PAM includes an FPGA which connects to the electronic box which will control the valves setting the pressures. The control PC runs CentOS 7, which is one of the OS supported by the FPGA driver.

The pam_interface provides a python API for:

- sending desired pressures to each muscle
- reading the sensors of the robot, which consist for each joint of:
  - the measured pressure
  - the encoder value
  - a boolean indicating if the encoder reference is found (more about this below)
  - the angular position of the joint
  - the angular velocity of the joint

The angular position of the joint is provided relative to the posture of the joint when the FPGA was started. This may not be very useful. The sensors of the robot will provide the absolute position of the joint once the joint crossed a "reference" middle position. If the "reference found" is true, then the joint crossed at some point this middle position and the angular position is absolute. If not, it is relative.

### Installation

#### On Ubuntu

pam_interface follows the [general guidelines of IRS](https://github.com/intelligent-soft-robots/intelligent-soft-robots.github.io/wiki), and is provided by the treep project PAM.

Ubuntu is not supported by the FPGA controlling the robot. Installing pam_interface allows only to run the pam server over a dummy virtual robot (see below), useful only for debug.

#### On the control desktop

The control desktop runs CentOS and should have all the required dependencies already installed.
You may therefore simply use treep to clone PAM, and compile as usual.

### Usage

#### Starting the server

After compilation and sourcing of the workspace, the pam_server is available and can be started:

```bash
pam_server
```

The above will start the server over a dummy simulated robot (no realistic physics, just for debug).
To start a server over the real robot:

```bash
pam_server real
```

The above obviously assumes you are working from the robot control workstation.
See somewhere below for the instructions on how to start the robot (beyond the server)


#### Printed data

Once the server started, it will print in the terminal for each of the 4 DOFs:

- the value of the encoder (if the reference has not been found), the angular position of the joint otherwise (in degree)
- the value of the observed and desired pressure for the agonist and antagonist muscles.

#### Sending desired pressures and reading sensors

In another terminal, you may start a script using the following API:

```python
segment_id = "pam_robot"

target_pressure_agos = [12000,14000,16000,13000]
target_pressure_antagos = [13000,15000,15000,12000]

# sending desired pressures to the robot
pam_interface.write_command(segment_id,agos,antagos)

# reading information from the robot
robot_state = pam_interface.read_robot_state(segment_id)
```

```{danger}
"write_command" does not proceed any security check. If you send desired pressures that are very different to the current desired pressures, violent motions are likely to occur.
```

robot_state is an instance of [RobotState](https://github.com/intelligent-soft-robots/pam_interface/blob/master/include/pam_interface/state/robot.hpp).

See its documentation [here](to do: point to the right url)

### Starting the real robot

#### Parts

- the "electronic box", which is turned on via the power outlet
- the pressure valve (against the wall). Horizontal means closed
- the emergency stop button, which blocks the pressure
- the control software server (pam_interface or o80_real)

```{warning}
What is to be avoided is to have the pressure applied to the robot when the electronic box is off or the electronic box is on but the FPGA has not been initialized (the FPGA is initialized by the control software server). 

The electronic box and the server ensure that the pressure applied to the robot is limited. If the robot is exposed to the pressure, while the electronic box is off or the FPGA has not been initialized, the maximal pressure will be applied to it and damage may occur.

**Applying the pressure is always the last thing to do**
```
```{important}
**What to do when in doubt:**
Press the emergency button.
```

#### Starting state

- power outlet off
- emergency button pressed
- pressure valve closed (horizontal)
- 4th degree of freedom of the robot "aligned" (silver paint marking aligned with zero)

#### Starting steps

 1. Start electronic box (switch power outlet on)
 2. Start o80_real and o80_console. o80_console should show * as angle values, as the reference for the encoder should not have been found yet. If o80_console shows angles, restart the desktop.
 3. Move the robot joints manually until an angle value is shown for all degree of freedome, except the last one.
 4. Align manually the last degree of freedom
 5. Stop the electronic box, and then restart it
 6. Start o80_real
 7. Release the pressure via the valve (put in a "vertical" stance)
 8. Release the emergency button

(the 4th degree of freedome has some encoder issue, which explains this convulated starting process).

#### Stopping steps

1. Stop server (software has pressure decrease on exit)
2. Press emergency button
3. Close pressure supply valve
5. Turn off electronics

### Checking the robot

The executable [pam_check](https://github.com/intelligent-soft-robots/pam_interface/blob/master/bin/pam_check) can be run once the server started and the pressure applied to the robot. It will apply pressure to each muscle one by one and generating plots of the observed/desired pressure.

```bash
pam_check
```

You may run the check over only (the two muscles of) 1 joint:

```bash
# only the first joint
pam_check 0 
```

## Method 2: O80 PAM

o80_real is a wrappers over [pam_interface](https://github.com/intelligent-soft-robots/pam_interface) providing {doc}`o80 <o80:index>` functionalities.

This documentation assumes you are familiar with both *pam_interface* and *o80*.

### Installation

Follow the [general guidelines](https://github.com/intelligent-soft-robots/intelligent-soft-robots.github.io/wiki), using either the treep project "PAM" or the treep project "PAM_MUJOCO" (if you'd like to use o80_real over a PAM robot simulated by MuJoCo).

If using mujoco, you also need to copy a mujoco licence key (mjkey.txt) in the folder /opt/mujoco/ (create the folder is necessary).

### Usage

#### Starting a o80 server

To start a server over a dummy robot (no real physics, no graphics, just for debugging purposes):

```bash
o80_dummy
```

To start a server over the real robot (on cent-os control desktop, **assuming you follow the procedure provided in the [pam_interface](https://github.com/intelligent-soft-robots/pam_interface) documentation**)

```bash
o80_real 
```

#### Checking all is working

Once the o80 server started, you may check all is working fine by running in another terminal:

```bash
o80_check
```

This executable will changes the pressure on each muscle one by one.

#### Performing a series of swing motion

```bash
o80_swing_demo
```

#### Python user code

See [Tutorials 1 to 3](B2_tutorial1) for examples of a pressure controlled robot.
The difference with the tutorials, which show interfacing with a mujoco simulated robot, is that no handle is required to access the frontend. Instead, the frontend can be accessed directly:

```python
import o80_pam
segment_id="real_robot" # default segment_id when starting o80_real
frontend = o80_pam.frontend(segment_id)
```

