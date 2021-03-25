main content: under construction

## sharing it via PyPi

[PyPi](https://pypi.org/) is the host service that makes an open source Python package installable via pip by anybody (i.e. without needing to clone the source code).

To register a package on PyPi, you need:

- to make the python package pip installable (see above)
- to create an account on [PyPi](https://pypi.org/) 

You may then, in a terminal, in the root folder of your package source folder, create the distributables:

```bash
python setup.py sdist bdist_wheel
```

This will create a "dist" folder (and other folder/files, which are good to list in the .gitignore file) and create the distributables in it. Note that this will create distributables for the Python version corresponding to the Python executable used (Python 2.7x or Python3.x). You can create distributables for several versions:

```bash
python setup.py sdist bdist_wheel
python3 setup.py sdist bdist_wheel
```

Once the distributables created, you can upload them to PyPi (this will upload all the distributables, i.e. you do not need to call this command with different Python versions) :

```bash
python3 -m twine upload dist/*
```

This will request your PyPi account and username, and upload the distributables. If you go to the PyPi website and login, you should be able to manage your package.

If your package is called "my_package", then it should be possible to (after some times, once PyPi "refreshed"):

```
pip install my_package # and/or pip3 install my_package
``` 

Be aware that:

>> The version of the package must be different for each upload

PyPi keeps the history of version, and two uploads can not have the same versions.
The version number must be updated in the setup.py file

More detailed information can be found [here](https://packaging.python.org/tutorials/packaging-projects/)

