cmake_minimum_required(VERSION 3.10.2)

project(pam_documentation)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED on)

################
# Dependencies #
################

find_package(ament_cmake REQUIRED)
find_package(mpi_cmake_modules REQUIRED)
ament_export_dependencies( mpi_cmake_modules )


# prepare to export all needed targets
set(all_targets)
set(all_target_exports)


#################
# documentation #
#################

add_documentation()


######################
# Install and export #
######################\

install(DIRECTORY include/ DESTINATION include)
install(DIRECTORY internal/ DESTINATION include)
install(
  TARGETS ${all_targets}
  EXPORT ${all_target_exports}
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
  RUNTIME DESTINATION bin
  INCLUDES
  DESTINATION include)
ament_package()

