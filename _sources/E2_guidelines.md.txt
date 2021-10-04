# Developer's guide 2: guidelines

This section describes the rules to follow to get new code integrated in any of the repository.

## Working on a git branch

Before starting to work on a repository, create a branch: your_name/what_you_will_work_on.

For example: vberenz/adding_eigen_support

Work on this branch and push as many commits as you wish.

## code update

When you update code, you must consider:

### unit-tests

Update existing unit tests or create new onces. Here are [examples](https://github.com/intelligent-soft-robots/context/blob/master/tests/unit_tests.cpp) of unit tests.

### demos

A demo is an executable that provides a usage example of the code. Demos should be a simple as short as possible. Demos are very useful for users to understand rapidly how the code work.

Typically, demos are hosted in packages (as for example [here](https://github.com/intelligent-soft-robots/pam_mujoco/tree/master/demos)).
When a demo requires code from various repositories, they can be hosted in a dedicated repository, as for example [pam_demos](https://github.com/intelligent-soft-robots/pam_demos).

### documentation

Documentation is written directly in the code, see for example this C++ [file](https://github.com/intelligent-soft-robots/o80/blob/master/include/o80/back_end.hpp).  Our code base currently does not have enough documentation, please help us doing better.

### formatting and guidelines

You must these [guidelines](https://machines-in-motion.github.io/code_documentation/ci_example_cpp/docs/doxygen/html/coding_guidelines_1.html).
For formatting c++ code, use the executable mpi_cpp_format (which should already be in your path if you followed the installation instruction):

```bash
cd Software/workspace/src/package
mpi_cpp_format .
```

For python code formatting, use python black:

#### installation

```bash
pip install black
```

#### usage

```bash
black /path/to/folder
```

## Merging to master branch

Once the code on the branch you are working on is ready (i.e. clean, tested, documented, formatted and with demos), you request for it to be merged with the master branch:

- visit the repository on github

- click on the link "Pull requests"

- create a new pull request, asign yourself and select reviewers using the web interface

- select an appropriate label.

It is good manner to squash all the commits of the branch before a code review (see below), as this makes the work of the reviewer easier. See for example these [instructions](http://gitready.com/advanced/2009/02/10/squashing-commits-with-rebase.html).

In the pull request text:

- describe what functionality you added or updated, and why

- describe how you know the code you wrote works (e.g. running unit tests and/or demos)

- confirm you followed the guidelines and used the formatting tools

Note that yourself will certainly also be requested to perform review. If so:

- check the guidelines have been followed

- check demos have been provided

- check the code is modular and properly commented

- check unit tests exist

- avoid requested micro optimization of the code, and request non consequentials modification of the code

- avoid requesting the development of new features (e.g. "this is useful, but you can also add ..."), as one could argue you could also add these extra features yourself. 






