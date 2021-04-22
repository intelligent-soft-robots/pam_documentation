## why a new package

You need to create a (catkin) package for:

- c++ code (possibly with Python bindings)
- python code that has dependencies of other catkin package

If you are writing a "standalone" python code, then you do not need to create new package. See this [[page|08_Creating a Python package]].

## recap

From the previous pages, you learned that:

- treep is used to clone project.
- a project consists of several repositories. 
- once the repositories of the project are cloned, they are a "workspace". 
- a workspace is compiled using catkin tools.

## what is a (catkin) package

We use the convention that a repository contains the code of one package (a repository *could* contain several package).
A package is a "compilation unit", characterized by a CMakeList.txt file and a package.xml file.

For example, this is a package:

[https://github.com/intelligent-soft-robots/context](https://github.com/intelligent-soft-robots/context)

- CMakeLists.txt is the "cmake" receipt for compilation
- package.xml provides some meta information about the package, including its dependencies on other packages

Typically, a package also contains one or several of:

- c++ code
- python code
- python bindings over c++ code

According to our convention, a package must also contain:

- unit tests ([example](https://github.com/intelligent-soft-robots/context/tree/master/tests))
- demos

This [[example|https://github.com/machines-in-motion/ci_example/blob/master/ci_example_cpp/CMakeLists.txt]] of a commented CMakeLists.txt file should help.

## creating a new package

- create a new repository. The name should by lower case and with underscores: **a_proper_name**. Create the repository on https://gitlab.is.tue.mpg.de/.

- Taking inspiration from this [package](https://github.com/intelligent-soft-robots/context), create the proper CMakeLists.txt and package.xml files. The name of the package as provided in these two files must be the same as the repository name

- If you are not familiar with caktin and/or cmake, ask Vincent for a rapid tutorial

- start writing code (see next wiki pages)




Our goal is to develop high quality tested code, so all packages must:

- follow our [coding guidelines](https://machines-in-motion.github.io/code_documentation/ci_example_cpp/docs/doxygen/html/coding_guidelines_1.html)
- be properly formatted
- have documentation
- have unit tests
- have demos
- have continuous integration

The rest of this page will provide information on all these points.

## guidelines

The programming guidelines are provided [here](https://machines-in-motion.github.io/code_documentation/ci_example_cpp/docs/doxygen/html/coding_guidelines_1.html). You must follow them carefully. 

## formatting

The guidelines request you to format the code in a specific way. To help with this, a script has been setup in the [mpi_cmake_modules](https://github.com/machines-in-motion/mpi_cmake_modules) package. This package is included in most of [treep projects](04_Cloning-a-project), and should therefore be in your workspace. Usage:

```bash
cd workspace
source devel/setup.bash
cd path/to/your/package
mpi_clang_format .
```

The above will update all c++ source files so that they matches the formatting guideline.

All code pushed to the master branch of a project **must** have been properly formatted.

## documentation

### doxygen documentation

All header files must have doxygen documentation. See for example all these [header files](https://github.com/intelligent-soft-robots/context/tree/master/include/context). 

Note that it is not required to document other source files.

The continuous integration job will automatically update our [software documentation page](https://intelligent-soft-robots.github.io/) to make this API documentation available online.

### extra documentation

To add extra information, you may:

- create a "doc" folder at the root of your package
- add markdown files to this folder

The content of the markdown files will be added to the online documentation by the continuous integration job (in their alphabetic order).

For example, these [files](https://github.com/intelligent-soft-robots/o80/tree/master/doc) result in this [documentation](https://intelligent-soft-robots.github.io/code_documentation/o80/docs/sphinx/html/general_documentation.html).

### activating documentation

The [CMakeLists.txt](https://github.com/intelligent-soft-robots/context/blob/master/CMakeLists.txt) must include the command for documentation build:

```cmake
# documentation 
add_documentation()
```

### compiling the documentation locally

The continuous integration job will compile the documentation and make it online. But if you wish to generate it locally, you may compile:

```bash
cd workspace
catkin config --cmake-args -DGENERATE_DOCUMENTATION=ON
catkin build
```
The documentation, if compiled successfully, will be in workspace/devel/share

## unit tests

We use [google tests](https://github.com/google/googletest/blob/master/googletest/docs/primer.md).
For obvious reason, your code must include unit tests.  

Example of a unit test folder is given [here](https://github.com/intelligent-soft-robots/context/tree/master/tests).

The unit testing must be activated in the CMakeList.txt file, for example:

```cmake
# unit tests
catkin_add_gtest(context_unit_tests 
  tests/main.cpp
  tests/unit_tests.cpp)
target_link_libraries(context_unit_tests context ${catkin_libraries})
```

The continuous integration job will run the unit tests and send notification if some tests do not pass.

To run all the unit tests of your workspace locally:

```bash
cd workspace
source ./devel/setup.bash
catkin run_tests
```

The results will be in: 

```bash
workspace/build/<package name>/test_results
```

You may see a summary via:

```bash
catkin_test_results workspace/build
```

### demos

A demo is an executable which purpose is to provide users of the package with a concrete example of its usage. Ideally, a demo is simple, covers most of the API, and has lots of comment.

For example, the package shared_memory has lots of [demos](https://github.com/machines-in-motion/shared_memory/tree/master/demos). If your workspace includes shared_memory, these demos can be executed after compilation:

```bash
cd workspace/devel/lib/shared_memory
./serialization # or another demo
```

## continuous integration

We use bamboo for continuous integration. Bamboo jobs are managed by Vincent. Bamboo is maintained by the [Software Workshop](https://is.mpg.de/en/software-workshop).

To ensure your package is covered by a continuous integration plan, contact Vincent.

The continuous integration:

- attempt to build workspaces
- attempt to generate the documentations
- upload the documentations to [https://intelligent-soft-robots.github.io/](https://intelligent-soft-robots.github.io/)
- attempt to build and run the unit tests

If any of the step above fails, a notification is sent to isr-software@tuebingen.mpg.de. Contact Vincent, or another IT admin, to be added to this mailing list.

Continuous integration jobs run weekly, and also every time some new content is pushed on master branches. 




We use [pybind11](https://pybind11.readthedocs.io/en/master/?badge=master) for creating wrappers over c++ code.

By convention, the c++ binding code should be in the srcpy folder of the package, and in the file wrappers.cpp.

As you can see in this [example](https://github.com/intelligent-soft-robots/context/blob/master/srcpy/wrappers.cpp), creating binders for c++ classes can be trivial.

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

The above results in the creation of the python package "context", which can be used after compilation and sourcing of the workspace, simply in a terminal:

```bash
python
```

then:

```python
import context
```





Everybody is encouraged to update and maintain our repositories. To ensure good quality and minimum debugging struggles, these guidelines must be observed:

## branching

Before starting to work on a repository, create a branch: your_name/what_you_will_work_on.

For example: vberenz/adding_eigen_support

Work on this branch and push as many commits as you wish.

## code update

When you update code, you must also:

- update the unit tests, create new unit tests if necessary
- update the demos, create new demos if necessary
- update the doxygen documentation
- format your code

see this [page](07_Writing-cpp-code) for more details

## squashing

It is good manner to squash all the commits of the branch before a code review (see below), as this makes the work of the reviewer easier.

See for example these [instructions](http://gitready.com/advanced/2009/02/10/squashing-commits-with-rebase.html)

## perform a pull request 

- After pushing your branch to origin, visit the repository on github and create a pull request. 
- Add at least a reviewer. Two reviewers is better. Select in priority someone in the lab who is using the code, someone else otherwise.
- Add yourself as assignees. 
- Select an appropriate label.
- Provide a description of the update, and confirm that:
    - you updated the unit tests
    - you updated the demos
    - you updated to doc
    - you applied the format
- Describe how you tested the code you are pushing work (if for some valid reason you did not update the unit tests).

## enjoy the review

The code review interface of Github is quite straightforward

## merge

Once the pull request approved, merge your branch (this can be done directly from the github pull request page)

## delete the branch

see this [page](https://www.freecodecamp.org/news/how-to-delete-a-git-branch-both-locally-and-remotely/)

## if you are reviewer

If you review some update, at minima you must check that all the guidelines has been followed (unit tests, demos, documentation, formatting). 

Check if you see any way the code could be improved, or if you see some errors.

To avoid :
- request for micro-optimization
- request for changes somehow arbitrary (would result in same performance, but you would find the code more beautiful based on subjective criteria)
- request for further change ("it would be nice to also have ...". One could argue you can do it yourself).






see [Max's doc](https://github.com/machines-in-motion/machines-in-motion.github.io/wiki/use_colcon)

To build and run the unit-tests:

```bash
colcon test 
```

with verbose output:

```bash
colcon test --event-handlers console_direct+
```

for selected package(s):

```bash
colcon test --packages-select package_name --event-handlers console_direct+
```
