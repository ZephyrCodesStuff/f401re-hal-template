# Set the minimum version of CMake that can be used
cmake_minimum_required(VERSION 3.20)

# Enable compile command to ease indexing with e.g. clangd
set(CMAKE_EXPORT_COMPILE_COMMANDS TRUE)
set(CMAKE_C_COMPILER_FORCED TRUE)
set(CMAKE_CXX_COMPILER_FORCED TRUE)

# Target MCU selection: STM32F401RE (default) or STM32G491RE
set(TARGET_MCU "STM32F401RE" CACHE STRING "Target MCU: STM32F401RE or STM32G491RE")
set_property(CACHE TARGET_MCU PROPERTY STRINGS STM32F401RE STM32G491RE)

# Set target definition variables required by the toolchain file
include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/target.cmake)

# Auto-detect ninja build tool across Linux (apt) and macOS (brew / ST bundles)
file(GLOB _CUBE_NINJA_DIRS
  "$ENV{HOME}/Library/Application Support/stm32cube/bundles/ninja/*/bin"
  "$ENV{HOME}/.stm32cube/bundles/ninja/*/bin"
)
if(NOT CMAKE_MAKE_PROGRAM)
  find_program(NINJA_EXECUTABLE NAMES ninja ninja-build
    PATHS
      ${_CUBE_NINJA_DIRS}
      "/opt/homebrew/bin"
      "/usr/local/bin"
      "/usr/bin"
  )
  if(NINJA_EXECUTABLE)
    set(CMAKE_MAKE_PROGRAM "${NINJA_EXECUTABLE}" CACHE FILEPATH "Path to ninja build tool" FORCE)
  endif()
endif()

# Auto-detect st-arm-clang compiler toolchain across Linux and macOS bundles
file(GLOB _CUBE_CLANG_DIRS
  "$ENV{HOME}/Library/Application Support/stm32cube/bundles/st-arm-clang/*/bin"
  "$ENV{HOME}/.stm32cube/bundles/st-arm-clang/*/bin"
)
find_program(STARM_CLANG_EXE NAMES starm-clang
  PATHS ${_CUBE_CLANG_DIRS}
)
if(STARM_CLANG_EXE)
  get_filename_component(_STARM_BIN_DIR "${STARM_CLANG_EXE}" DIRECTORY)
  set(ENV{PATH} "${_STARM_BIN_DIR}:$ENV{PATH}")
  list(PREPEND CMAKE_PROGRAM_PATH "${_STARM_BIN_DIR}")
endif()

# Set the toolchain file for cross-compilation
include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/starm-clang.cmake)

# Project definition
project(sandbox)

# Enable CMake support for ASM and C/CPP languages
enable_language(C CXX ASM)

set(PROJECT_NAME sandbox)

# Create an executable object type
add_executable(${PROJECT_NAME})

# Optional CMSIS-RTOS v2 wrapper (CubeMX compatibility: osEventFlagsWait, osThreadNew, etc.)
option(ENABLE_CMSIS_OS2 "Enable CMSIS-RTOS v2 API wrapper over FreeRTOS" ON)

# Include additional CMake files for flags, components, and files
include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/flags.cmake)
include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/components.cmake)
include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/files.cmake)
include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/hal.cmake)

if(ENABLE_CMSIS_OS2)
  include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/freertos-cmsis.cmake)
else()
  include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/freertos.cmake)
endif()

# Add sources to executable/library
target_sources(${PROJECT_NAME} PRIVATE
  # User defined sources
)

# Add include directories
target_include_directories(${PROJECT_NAME} PRIVATE
  # User defined include directories
)

# Compiler options
target_compile_options(${PROJECT_NAME} PRIVATE
  # User defined compiler options
)

# Add additional defined symbols
target_compile_definitions(${PROJECT_NAME} PRIVATE
  # Add additional defined symbols here
)

# Linker options
target_link_options(${PROJECT_NAME} PRIVATE 
  # User defined linker options
)

# Add additional linker search directories
target_link_directories(${PROJECT_NAME} PRIVATE
  # Add additional linker search directories here
)

# Add additional linker libraries
target_link_libraries(${PROJECT_NAME} PRIVATE
  # Unified Hardware Abstraction Library for STM32
  stm32_hal

  # FreeRTOS Kernel (or CMSIS-RTOS2 wrapper)
  $<$<BOOL:${ENABLE_CMSIS_OS2}>:cmsis_os2>
  $<$<NOT:$<BOOL:${ENABLE_CMSIS_OS2}>>:freertos_kernel>
)
