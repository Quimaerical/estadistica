cmake_minimum_required(VERSION 3.14)
project(stat_engine VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

include(FetchContent)

# Dependencia: gcem (Generalized Constant Expression Math)
FetchContent_Declare(
    gcem
    GIT_REPOSITORY https://github.com/kthohr/gcem.git
)
FetchContent_MakeAvailable(gcem)

# Dependencia: stats (C++ Statistical Software Library)
FetchContent_Declare(
    stats
    GIT_REPOSITORY https://github.com/kthohr/stats.git
)

FetchContent_MakeAvailable(stats)

set(SOURCES src/hypothesis.cpp src/anova_rlm.cpp)
# Creado para FFI
add_library(stat_engine SHARED ${SOURCES})

target_include_directories(stat_engine PUBLIC 
    include
    ${stats_SOURCE_DIR}/include
    ${gcem_SOURCE_DIR}/include
)

set_target_properties(stat_engine PROPERTIES
    C_VISIBILITY_PRESET hidden
    CXX_VISIBILITY_PRESET hidden
    VISIBILITY_INLINES_HIDDEN YES
)
