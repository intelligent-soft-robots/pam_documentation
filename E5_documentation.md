# Developer's guide: Updating the documentation

## This documentation

This documentation is hosted by the git repository: [https://github.com/intelligent-soft-robots/pam_documentation](https://github.com/intelligent-soft-robots/pam_documentation).
Everybody is welcome to update/extend it.

For doing so:

1. Clone the documentation [repository](https://github.com/intelligent-soft-robots/pam_documentation)
2. Update the documentation
3. If you add a new file: list it in the file index.rst (at the right place, are files are in order)
4. If you add a new file: note that both RST files and MD files are supported. 
5. Check the documentation looks nice locally: you can generate the html files with ```make html``` (see requirements.txt).
6. Push to a branch and perform a pull request to the main branch.

After review and once the branch is merged into the main branch, the online documentation will be automatically updated.

## Documentation of all packages

The software comprises several packages.
These are the packages that are downloaded via treep when installing the software from source and using colcon as described [here](A1_overview_and_installation).
Some of these package have documentation, which can be built locally

### How to build

Using colcon:

```bash
cd /path/to/Software
cd workspace
colcon build --cmake-args ' -DCMAKE_BUILD_TYPE=Release ' -DGENERATE_DOCUMENTATION=ON
```

For this to work, you may need to pip install some packages: m2r, mistune (version 0.8.4), recommonmark, sphinx, sphinxcontrib-moderncmakedomain, breath.

Once compilation is successfully finished, html documentation can be found in paths:

```
/path/to/Software/workspace/install/<package name>/share/<package name>/docs/
```

### How to have the documentation building for a package

To have the documentation built for a package using the method above, this command has to be added to
the ```CMakeLists.txt``` file of the package:

```cmake
add_documentation()
```

The command add_documentation is provided by the package mpi_cmake_modules, which is part of the colcon workspace
as downloaded by treep (see this [page](A1_overview_and_installation))








