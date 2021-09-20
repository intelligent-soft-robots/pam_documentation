# Developer's guide 2: Guidelines

This section describes the rules to follow to get new code integrated in any of the repository.

## Working on a git branch

Before starting to work on a repository, create a branch: `your_name/what_you_will_work_on`.

For example: `vberenz/adding_eigen_support`

Work on this branch and push as many commits as you wish.

## Code Update

When you update code, you must consider:

### Unit Tests

Update existing unit tests or create new ones. Here are [examples](https://github.com/intelligent-soft-robots/context/blob/master/tests/unit_tests.cpp) of unit tests.

### Demos

A demo is an executable that provides a usage example of the code. Demos should be a simple as short as possible. Demos are very useful for users to understand rapidly how the code work.

Typically, demos are hosted in packages (as for example [here](https://github.com/intelligent-soft-robots/pam_mujoco/tree/master/demos)).
When a demo requires code from various repositories, they can be hosted in a dedicated repository, as for example [pam_demos](https://github.com/intelligent-soft-robots/pam_demos).

### Documentation

#### Code Documentation

All code shall be documented in-source.  This means that every function, class,
struct, global variable, etc., needs to have a docstring/comment containing some
documentation in:
- [Google style](https://sphinxcontrib-napoleon.readthedocs.io/en/latest/example_google.html)
    for Python,
- [Doxygen](http://www.doxygen.nl/manual/index.html) format for C++.

If the definition and declaration are separated (C++), Doxygen should be in
the header, not the cpp file. **Please do not duplicate!**.

Make the documentation as compact as possible. Avoid boilerplate formulations
that do not add useful information, e.g. instead of
"This function returns foobar" simply write "Returns foobar".

Also add regular comments to the code whenever you feel that they would help a
future reader to more easily understand what that code is doing.

See [this file](https://github.com/intelligent-soft-robots/o80/blob/master/include/o80/back_end.hpp)
for an example in C++.  Our code base currently does not have enough
documentation, please help us doing better!

#### Package Documentation

More general documentation of a package (e.g. describing how to run the software
on the robot) can be written in separate reStructuredText-files that are stored
in a folder `doc/` inside the package.

#### Build the Documentation

If you are using CMake, the package may include the `mpi_cmake_modules` package
and in the CMakeLists.txt file call the `add_documentation()` macro.  The
documentation can then be build via

    colcon build --cmake-args -DGENERATE_DOCUMENTATION=ON

Once built, the documentation can then be found in
`build/package_name/share/docs/sphinx/html`.


### Code Style Guide

#### Formatting

We are using auto-formatting tools to format our code.  So while writing your
code, you don't have to worry about things like indentation, spaces, brace
positions, etc.  Simply run the corresponding tool (depending on the language)
on the file before committing your changes.

For **C++**, use the executable `mpi_cpp_format` (which should already be
in your path if you followed the installation instruction):

```bash
mpi_cpp_format path/to/file_or_folder
```
If a folder is given, it searches for C++ files recursively.


For **Python**, use [Black](https://black.readthedocs.io) (it can easily be
installed via `pip install black`):

```bash
black path/to/file_or_folder
```

#### Naming Conventions

Give as descriptive a name as possible, within reason. Do not worry about saving
horizontal space as it is far more important to make your code immediately
understandable by a new reader. Do not use abbreviations that are ambiguous or
unfamiliar to readers outside your project, and do not abbreviate by deleting
letters within a word. Abbreviations that would be familiar to someone outside
your project with relevant domain knowledge are OK. As a rule of thumb, an
abbreviation is probably OK if it's listed in Wikipedia.

Formatting of names should be as follows:

- Package names: `lower_case_with_underscores`
- Repositories should be named exactly the same as the package they contain.
- Types (classes, structs, ...): `FirstUpperCamelCase`
- Functions, methods: `lower_case_with_underscores`
- Variables: `lower_case_with_underscores`
    - **[C++ only]** Class members: `like_variables_but_with_trailing_underscore_`
- Constants: `UPPER_CASE_WITH_UNDERSCORES`
- Global variables: Should generally be avoided but if needed, prefix them with
    g_, i.e. `g_variable_name`.


##### Add Units to Variable Names

Variables that hold values of a specific unit should have that unit appended to
the name.  For example if a variable holds the velocity of a motor in *krpm* it
should be called `velocity_krpm` instead of just `velocity`. Some more examples:

- `voltage_mV`
- `duration_us` (use "u" instead of "µ")
- `acceleration_mps2` (m/s^2)


#### Python-Specific Guidelines

- Follow [PEP 8](https://www.python.org/dev/peps/pep-0008/).
  - Exception: For the line length we use Black's default of 88 characters.  If
    for a specific package you need to stick with 79 instead (e.g. due to
    external requirements), add a file `pyproject.toml` with the following
    content to the package:

        [tool.black]
        line-length = 79
- It is recommended to run a linter like [flake8](https://flake8.pycqa.org) and
  fix any warnings that it shows.  When used in combination with Black, you may
  use the following configuration:

      [flake8]
      max-line-length=88
      ignore=E203,W503


#### C++-Specific Guidelines

##### Folder Structure and File Naming

General folder structure of a package with C++ code:

    <package_name>
    │
    ├── include
    │   └── <package_name>   <-- Header files go here
    │       └── foo.hpp
    ├── src                  <-- cpp-files go here
    │   └── foo.cpp
    ...

- Header files have file extension `.hpp` and go to `include/<package_name>/`.
- Source files have file extension `.cpp` and go to `src/`.
- When using templates:  If you want to separate declaration and definition, put
  the declaration to a `.hpp` header file as usual and the definition to a file
  with extension `.hxx` in the same directory (which is included at the bottom
  of the `.hpp` file).
- Preferably each class should be in a separate file with name
  `class_name_in_lower_case.*`.  However, this is not a strict rule, if several
  smaller classes are logically closely related, they may go to the same file.
- Executable scripts shall be placed in the `scripts/` folder. And should have
  a CMake **install rule** that makes them executable upon installation.
- The C++/pybind11 code for wrapping C++ code to Python shall be placed in
  `srcpy/`

##### Always add braces

**Always** add braces for single-line if/loop/etc.  They may seem unnecessary
but they highly reduce the risk of introducing bugs if the block is extended in
the future.

```cpp
// good:
if (condition)
{
    foo();
}

// bad:
if (condition)
    foo();
```


##### Pass objects by const reference

In general, non-primitive data types should be passed to functions by const
reference to avoid unnecessary copies.

```cpp
void foobar(const Foo &foo);  // good
void foobar(Foo foo);  // results in copy of `foo`. Only do this if there is a
                       // specific need for it.
```

##### pragma once vs Include Guards

Prefer `#pragma once` over include guards.  `#pragma once` is not part of the
official standard but is widely supported by compilers and much easier to
maintain.

Note that there are some border cases where `#pragma once` is causing issues
(e.g. on Windows or when having a weird build setup with symlinks or copies of
files). In such cases use traditional include guards. Make sure they have unique
names by composing them from the package name and the path/name of the file
(e.g. `MY_PACKAGE_PATH_TO_FILE_FILENAME_H`). Please **do not** add underscores
as prefix or suffix because this is reserved for the compiler pre-proccesor
variables.

##### Keep scopes small

Avoid adding anything to the global namespace if possible. This means

- Use a namespace when defining extern symbols.
- Use an anonymous namespace or static for symbols that are only used internally.

Generally define symbols in the smallest possible scope, i.e. if a variable is
only used inside one loop, define it inside this loop (however, do not consider
this to be a very strict rule, deviate from it where it seems reasonable).

##### Use types with explicit sizes

The header *stdint* defines primitive types with explicit sizes:
*int32_t*, *uint32_t*, *int16_t*, ...
They should be preferred over the build-in types int, unsigned, short, ...
To use them add the following include:

    #include <stdint>


## Merging to master/main branch

Once the code on the branch you are working on is ready, you request for it to
be merged with the master branch.


### Before opening a pull request

Before you create a pull request (or at least before you assign reviewers):
- Rebase your branch on the latest master/main to make sure there have been no
  conflicting changes in the meantime.
- Remove any debug code or commented code that is not needed anymore.
- Test all new features and also existing ones if they are affected by your
  change.  Unit tests are great for this!
- Document new features and update existing documentation if something changed.
- Add new unit tests and demos where appropriate.
- Run the auto-formatting tools on all new/modified files (see above).

### Creating a pull request

- Visit the repository on GitHub,
- click on the link "Pull requests",
- create a new pull request, assign yourself and select reviewers using the web
  interface,
- select an appropriate label.

It is good manner to squash all the commits of the branch before a code review (see below), as this makes the work of the reviewer easier. See for example these [instructions](http://gitready.com/advanced/2009/02/10/squashing-commits-with-rebase.html).

In the pull request text:

- describe what functionality you added or updated, and why
- describe how you know the code you wrote works (e.g. running unit tests and/or demos)
- confirm you followed the guidelines and used the formatting tools

### During the review

- The reviewers will take a look at your changes and may have some comments
  asking for clarifications or requesting changes.  Address all their comments.
- To address change requests, you can simply push more commits to the
  corresponding branch.  They will automatically show up in the pull request and
  reviewers get a notification.
- While the review is ongoing, avoid modifications of the git history (e.g.
  amending or squashing of commits).  This way the reviewers can more easily see
  what changes you made since their last review.
- You may only merge the pull request once all reviewers have approved.

### Merging a pull request

Once all reviewers have approved, you can merge the pull request via the web
interface.

Before merging, you may clean up the git history (e.g. squash commits).

After merging, **delete** the corresponding branch.  **Do not continue to use
the branch** after it was merged as this will likely cause a lot of chaos and
confusion later on.


### Some general rules for pull requests:

- To make life easier for the reviewers and to get your changes merged faster
  (thus reducing the risk of merge conflicts), try to keep merge requests rather
  small. This means that, where possible, a bigger task should be split into
  smaller sub-tasks that can be merged one after another instead of putting
  everything in one huge merge request.
- Do not add functional changes and major reformatting in the same commit as
  this makes review of the functional changes very difficult.


### On which packages is code review required?

Changes on core packages (e.g. `shared_memory`, `o80`, ...) must be reviewed by
at least one maintainer before they are merged.

On project-specific repositories on which no one else depends, reviews are still
encouraged but not mandatory (e.g. it may not be useful to review every change
while experimentation is still ongoing).  However, the code should be reviewed
before it is executed on a real robot.


## Being a Reviewer

Note that yourself will certainly also be requested to perform review. If so:

- **Try to provide reviews in a timely manner**. The contributor may be blocked in
  continuing their work while the pull request is under review.
- When reviewing, check the following things:
    - Is the code modular and properly commented?
    - Is the style guide followed?
    - Are new features/changes properly documented?
    - Are there unit tests/demos for new features?
    - And of course: Do the changes look reasonable and correct?
- Avoid requesting micro optimizations and non-consequential modifications of
  the code.
- Avoid requesting the development of new features (e.g. "this is useful, but
  you can also add ..."), as one could argue you could also add these extra
  features yourself.
- **Do not merge**, just approve the pull request if everything is okay.  Actual
  merging is done by one who contributed the pull request.  An exception is of
  course, if the contributor does not have the permissions to merge themselves
  on the corresponding repository.  In this case, check first, if the git
  history of the branch should be squashed first.
