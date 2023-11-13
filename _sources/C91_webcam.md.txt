# More info: Webcams

The package o80_webcam offers o80 wrappers of usb cameras.


## How-to

Start the executable:

```
# to see possible arguments
o80_webcams -h

# start standalone for all webcams
o80_webcams

# same, but does not display the webcam images
o80_webcams -no-display

# starts standalone only for webcam 0 and 1
o80_webcams 0 1

# start standalone for all webcams
# and set the o80 frequency at 100Hz
# (default is 50Hz)
# note: this does not change the frame rate
#       of the webcam itself !
o80_webcams --frequency 100

# start standalone for all webcams,
# and switch the displayed image every
# 5 seconds (default is 4)
o80_webcams --turnover 5
```

This will start o80 standalones for all connected usb webcams, and print in the terminal
the related segment ids, for example:

```bash
-- started standalones with segment_ids --
o80_webcam_0
o80_webcam_1
```

In another program, you may then access the webcam images, for example:

```
import o80_webcam
import numpy as np
frontend = o80_webcam.FrontEnd("o80_webcam_0")
obs = frontend.latest()
frame = obs.get_frame()
dimensions = obs.get_dimensions()
img = np.array(frame, dtype=np.uint8).reshape(dimensions)
```

## Changing the resolution

Currently, the resolution can only be determined at compile time.
Edit the file ```o80_webcam/include/o80_webcam/webcam.hpp```, update ```O80_WEBCAM_WIDTH```
and ```O80_WEBCAM_HEIGHT```; and recompile.

This assumes opencv will be able to set the configuration of the webcam accordingly. At runtime,
this will be called under the hood:

```cpp
// camera is an instance of cv::VideoCapture
camera.set(cv::CAP_PROP_FRAME_WIDTH, O80_WEBCAM_WIDTH);
camera.set(cv::CAP_PROP_FRAME_HEIGHT, O80_WEBCAM_HEIGHT);
```

If the requested resolution is not supported, this may fail and the program will crash at startup.

Also, RGB images require a relatively large memory, and the program may fail at startup to create a shared memory segment of the required size. You may need to either lower the resolution, or reduce the size of the o80 shared memory history, i.e. edit the file ```o80_webcam/include/o80_webcam/webcam.hpp``` (change the value of ```STANDALONE_QUEUE_SIZE```).
