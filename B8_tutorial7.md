# Tutorial 7: Converting observations to other formats

## Introduction

As shown in all previous tutorials, data is stored as instances of Observation.
Manipulating instances of Observation requires the installation of the whole software, which may be sometimes inconvenient.
Therefore, we provide functions for converting instances of Observation to *Numpy arrays*, *Pandas dataframes* and *dictionaries*.
Also, list of instances of Observation can be saved as pickled Pandas dataframes into files. 

## Numpy

```python
import numpy as np
import o80_pam
from o80_pam import observation_convertors as conv

observation = o80_pam.Observation()

# Converting to numpy array
# Order of values: 
# iteration, frequency, time stamp, positions (4d), velocities (4d),
# desired pressures (8d), observed pressures (8d), references found (4d)
np_array = conv.observation_to_numpy(observation)

# Converting to native python dictionary
d = conv.numpy_to_dict(np_array)

# Converting back to an instance of Observation
observation = conv.numpy_to_observation(np_array)

# Converting several observations at once
obs1 = o80_pam.Observation()
obs2 = o80_pam.Observation()
# np_ndarray: matrix, each row corresponding to an observation
# columns: a list of string providing explicit names to the
           columns of np_ndarray
np_ndarray, columns = conv.observations_to_numpy((obs1, obs2))
```

## Pandas

```python
import pandas as pd
from pathlib import Path
import o80_pam
from o80_pam import observation_convertors as conv


obs1 = o80_pam.Observation()
obs2 = o80_pam.Observation()

# converting to pandas dataframe
df = conv.observations_to_pandas((obs1,obs2))

# saving the dataframe to a file
path = Path("/path/to/file")
df.to_pickle(str(path)) 

# saving the observations directly as dataframe
# in a file
conv.pickle_observations((obs1,obs2), path)

# reading the file (to pandas dataframe)
df = read_pandas(path)
```

## Python dictionaries

```python
import o80_pam
import numpy as np
from o80_pam import observation_convertors as conv

obs = o80_pam.Observation()

# convert to numpy
np_array = conv.observation_to_numpy(observation)

# convert to dict
d = conv.numpy_to_dict(np_array)

# convert back to observation
obs = conv.dict_to_observation(d)

# creating an instance of Observation
# from a dict
d = {
  "iteration": 13,
  "frequency": 100,
  "time_stamp": 12,
  "positions": [1.0, 2.0, 3.0, 4.0],
  "velocities": [10.0, 20.0, 30.0, 40.0],
  "desired_pressures": [10, -10, 20, -20, 30, -30, 40, -40],
  "observed_pressures": [11, -11, 21, -21, 31, -31, 41, -41],
  "references_found": [True, True, False, True],
}
obs = conv.dict_to_observation(d)
```
