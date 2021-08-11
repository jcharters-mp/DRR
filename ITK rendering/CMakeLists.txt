# This is the root ITK CMakeLists file.
cmake_minimum_required(VERSION 3.10.2 FATAL_ERROR)
foreach(p
    ## Only policies introduced after the cmake_minimum_required
    ## version need to explicitly be set to NEW.
    CMP0070 #3.10.0 Define ``file(GENERATE)`` behavior for relative paths.
    CMP0071 #3.10.0 Let ``AUTOMOC`` and ``AUTOUIC`` process ``GENERATED`` files.
    )
  if(POLICY ${p})
    cmake_policy(SET ${p} NEW)
  endif()
endforeach()

# set path of ITK binary
SET(ITK_DIR "C:/MYDOCS/ITK-5.1.1-bin")

# This project is designed to be built outside the Insight source tree.
project(DRR-ITK)

# Find ITK.
find_package(ITK REQUIRED)
include(${ITK_USE_FILE})

add_executable(DRR DRR.cxx)
target_link_libraries(DRR ${ITK_LIBRARIES})

add_executable(ReadDicom ReadDicom.cxx)
target_link_libraries(ReadDicom ${ITK_LIBRARIES})
