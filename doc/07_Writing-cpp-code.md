
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


