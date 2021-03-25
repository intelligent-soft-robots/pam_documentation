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



