# Developer's guide 1: Tools

This guide is here for those who would like to upgrade/extend PAM's software (as opposed to use it in their own code).

For updating the code, the colcon workspace installation is required, as described {ref}`here <install_via_colcon>`.

The workflow is based on these tools: GitHub, treep, ament, colcon, pybind11 and gtest.

## GitHub

The source repositories are hosted in the "Intelligent Soft Robots" [domain](https://github.com/intelligent-soft-robots) of github.
As treep (see below) uses SSH, you need to register your SSH key to GitHub (see [here](https://docs.github.com/en/github/authenticating-to-github/adding-a-new-ssh-key-to-your-github-account))

## Treep

To get the software compiled and running, several Git repositories must be cloned.
As it would be annoying to clone them one by one, we use the project manager [treep](https://pypi.org/project/treep/), which allows to clone several repositories at once.

### Installation

```bash
pip install treep
```

### Configuration repository

treep needs a configuration folder. We use [treep_isr](https://github.com/intelligent-soft-robots/treep_isr.git):

```bash
mkdir Software # or another folder name
cd Software
git clone https://github.com/intelligent-soft-robots/treep_isr.git
```

In the folder treep_isr, you will find the file *repositories.yaml* which provides repositories names, URL and default branch (see also configuration.yaml). Once treep_isr has been cloned, you may see for example the list of repositories:

```bash
treep # treep without argument prints some help
treep --repos
```

Projects (i.e. repositories grouped together) are described in *projects.yaml*.
To see the list of projects:

```bash
treep --projects
```

To see information about a specific projects:

```bash
treep --project PAM_MUJOCO
```

### Cloning

You can use treep to clone a project (i.e. cloning all the repositories of the project):

```bash
treep --clone PAM_MUJOCO
```

### Status

The status argument is very useful to see the (git) status of each cloned repos (i.e. if they are behind origin, beyond origin, have modified files, etc.)

```bash
treep --status
```

### Pull 

You can use treep to update all the repositories

```bash
treep --pull
```


### Calling from anywhere

Note that you do not need to be in the Software folder to call treep, you may call treep for any of its subfolder, e.g.

```bash
cd Software/workspace/src/pam_interface
treep --status # still provides the status of all repositories.
```

## Ament packages

(Almost) all repositories contain the code for an ament package. An ament package is a "extended" CMake package, i.e. ament provides some cmake functionalities meant to make developers life easier. The documentation can be found [here](https://docs.ros.org/en/foxy/Guides/Ament-CMake-Documentation.html).

An ament package contains typically:

- C++ code, in the include/package_name and the source folders

- Python wrappers over this C++ code in the srcpy folder

- Native python code in the python folder

- Unit tests in the tests folder

- Configuration files

- A demos folder containing source code providing example of usage of the code provided by the package

- A package.xml file listing dependencies

- A CMakeLists.txt file containing the CMake commands required for compilation.

The [context](https://github.com/intelligent-soft-robots/context) and [pam_interface](https://github.com/intelligent-soft-robots/pam_interface) repositories provide examples of a packages containing most of the above.

## Colcon

### Overview

After cloning a workspace using treep, the workspace/src folder contains a collection of ament packages.
Colcon is the tool used for compiling all these packages:

```bash
cd Software/workspace
colcon build # will attempt to compile the whole workspace
```

If the compilation succeed, the workspace folder will contain the "install" folder which contains the binaries and python packages that result from the compilation.

To be able to "use" the code (i.e. adding executables to path, adding the python package to the python path, adding the libraries to the ld path ...), one must "source" the file Software/workspace/install/setup.bash:

```bash
cd Software/workspace/install
source setup.bash
```

This operation must be done in all new terminal. It is therefore recommanded to add to the ~/.bashrc file (which is sourced everytime a new terminal is opened):

```bash
echo "- sourcing workspace"
source /path/to/Software/workspace/install/setup.bash
```

### Compiling only one package

To compile only one specific package:

```bash
cd Software/workspace
colcon list # list all packages in the workspace
colcon build --packages-up-to packagename
```

This will compile only the selected package and its required dependencies.


## Pybind11

Most of the code is in C++, but made available as Python package.

We use [pybind11](https://pybind11.readthedocs.io/en/master/?badge=master) for creating wrappers over C++ code.

By convention, the C++ binding code should be in the srcpy folder of the package, and in the file wrappers.cpp.

As you can see in this [example](https://github.com/intelligent-soft-robots/context/blob/master/srcpy/wrappers.cpp), creating binders for C++ classes can be trivial.

For example, this wrapper code:

```cpp
   pybind11::class_<Ball>(m, "Ball")
        .def(pybind11::init<int>())
        .def("update", &Ball::update)
        .def("get", &Ball::get);
```

binds this c++ class [ball](https://github.com/intelligent-soft-robots/context/blob/master/include/context/ball.hpp).

The following calls has to be added in the CMakeLists.txt file:

```cmake
pybind11_add_module(context_py srcpy/wrappers.cpp)
target_link_libraries(context_py PRIVATE context ${catkin_LIBRARIES})
set_target_properties(context_py PROPERTIES
  LIBRARY_OUTPUT_DIRECTORY ${CATKIN_DEVEL_PREFIX}/${CATKIN_GLOBAL_PYTHON_DESTINATION}
  OUTPUT_NAME context)
install(TARGETS context_py DESTINATION ${CATKIN_GLOBAL_PYTHON_DESTINATION})
```

(replace "context" by the name of the catkin package).

Note that in the [wrappers.cpp](https://github.com/intelligent-soft-robots/context/blob/master/srcpy/wrappers.cpp#L12
) file, the package name must also be used as first argument:

```cmake
PYBIND11_MODULE(context, m)
```

The above results in the creation of the Python package "context", which can be used after compilation and sourcing of the workspace, simply in a terminal:

```bash
python
```

then:

```python
import context
```

## Unit tests

We use google tests for unit tests. See the [tests folder](https://github.com/intelligent-soft-robots/context/tree/master/tests) of the context package for a simple example to follow.

To run all the unit tests included in the package, run:

```bash
cd Software/workspace
colcon test --event-handlers console_direct+
```

To run the unit test of a selected package:

```bash
colcon test --packages-select package_name --event-handlers console_direct+	
```
