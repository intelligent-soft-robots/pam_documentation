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

