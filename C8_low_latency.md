# More info: Low latency kernel

On the desktop used to control the real robot, it is adviced (but not mandatory) to use a low latency kernel.

## How to evaluate the latency of the kernel

Clone pam_demos:

```
git clone https://github.com/intelligent-soft-robots/pam_demos.git
```

In a first terminal, start a dummy robot, using the default configuration:

```
o80_dummy
```

start the frequency check demos:

```
cd /path/to/pam_demos/frequency_check
python ./frequency.py
```

This will display some stats regarding the frequency at which the backend
is running. Here an example of results obtained using a regular kernel
(results may grandly vary depending on the hardware and kernel version):

```
Frequency monitoring, over 10001 iterations
	expected frequency: 500.0
	spikes over 525.0: 45 (0.44995500449955006%)
	spikes over 550.0: 20 (0.1999800019998%)
	spikes below 475.0: 40 (0.3999600039996%)
	spikes below 450.0: 19 (0.18998100189981001%)
	max frequency observed: 35625.22265764161
	min frequency observed: 209.46764426612697
	average frequency (spikes excluded): 500.1007930571098
	standard deviation (spikes excluded): 7.307281438308859
```

You can also visually observe the variations in frequency by using ```o80_plotting```
(simply call ```o80_plotting``` in a terminal).


## How to install the low latency kernel

### install the kernel

In a terminal:

```
sudo apt install linux-lowlatency
```


### update grub

Install grub-customizer:

```
sudo apt install grub-customizer
```

Use grub-customizer to select the low latency kernel to
be selected at startup (simply type "grub-customizer" in a terminal
to start it).

Then reboot.


### Make sure the low latency kernel is used:

In a terminal:

```
uname -a
```

The output should display a string containing "lowlatency".
Here an output example:

```
Linux severus 5.4.0-113-lowlatency #127-Ubuntu SMP PREEMPT Wed May 18 15:12:18 UTC 2022 x86_64 x86_64 x86_64 GNU/Linux
```

*note:* the command 'uname -a' is used during compilation of the software to check wether or not the kernel has low latency.
If this command does not output something containing 'lowlatency', the software will not make use of the low latency.

### Further setup

Create a group called "realtime":

```
sudo groupadd realtime
```

Add yourself and other users of the robot to this group 
(replace "username"):

```
sudo usermod -aG realtime username
```

Open the access to /dev/cpu_dma_latency, by adding to /etc/rc.local:

```
#!/bin/bash
sudo chmod 0666 /dev/cpu_dma_latency
```

Create a file /etc/security/limits.d/99-realtime.conf and add to it:

```
@realtime   -   rtprio  99
@realtime   -   memlock unlimited
```

Reboot the desktop.

## Reinstalling pam software

After setting up the low latency kernel, the software must be recompiled. It is advised to recompile it from scratch.

To double check the software has been compiled using low latency capabilities, in a terminal:

```
o80_dummy
```

An output similar to this one is expected:


```
[o80 PAM segment_id: real_robot | INFO 2022-06-08 10:49:14,011] read configuration
[o80 PAM segment_id: real_robot | INFO 2022-06-08 10:49:14,011] starting robot: dummy
[o80 PAM segment_id: real_robot | INFO 2022-06-08 10:49:14,011] cleaning shared memory
[o80 PAM segment_id: real_robot | INFO 2022-06-08 10:49:14,012] starting standalone
[o80 PAM segment_id: real_robot | INFO 2022-06-08 10:49:19,572] setting pressures to minimal values
[o80 PAM segment_id: real_robot | INFO 2022-06-08 10:49:21,156] init exit signal handler
[o80 PAM segment_id: real_robot | INFO 2022-06-08 10:49:21,167] running ...
[o80 PAM segment_id: real_robot | INFO 2022-06-08 10:49:26,173] running ...
```

Here is an ouput when the software has not been compiled for low latency
(notice the warning):

```
[o80 PAM segment_id: real_robot | INFO 2022-06-08 10:49:14,011] read configuration
[o80 PAM segment_id: real_robot | INFO 2022-06-08 10:49:14,011] starting robot: dummy
[o80 PAM segment_id: real_robot | INFO 2022-06-08 10:49:14,011] cleaning shared memory
[o80 PAM segment_id: real_robot | INFO 2022-06-08 10:49:14,012] starting standalone
warning this thread is not going to be realtime
[o80 PAM segment_id: real_robot | INFO 2022-06-08 10:49:19,572] setting pressures to minimal values
[o80 PAM segment_id: real_robot | INFO 2022-06-08 10:49:21,156] init exit signal handler
[o80 PAM segment_id: real_robot | INFO 2022-06-08 10:49:21,167] running ...
[o80 PAM segment_id: real_robot | INFO 2022-06-08 10:49:26,173] running ...
```

You may once more check the frequencies using the ```frequency_check``` demo. Here an output obtained
when using a low latency kernel:

```
Frequency monitoring, over 10001 iterations
	expected frequency: 500.0
	spikes over 525.0: 0 (0.0%)
	spikes over 550.0: 0 (0.0%)
	spikes below 475.0: 0 (0.0%)
	spikes below 450.0: 0 (0.0%)
	max frequency observed: 507.0101762012465
	min frequency observed: 491.56402400208816
	average frequency (spikes excluded): 500.0132872386277
	standard deviation (spikes excluded): 2.5699205319389224
```



