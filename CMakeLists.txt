cmake_minimum_required(VERSION 3.10)
project(Amalgam)

find_program(NUGET_EXE NAMES nuget PATHS "${CMAKE_SOURCE_DIR}/../ThirdParty/NuGet")
if (NOT NUGET_EXE)
    message("NUGET.EXE not found.")
    message(FATAL_ERROR "Please install this executable, and run CMake again.")
endif()

execute_process(
COMMAND
    ${NUGET_EXE}
    restore
    ${CMAKE_SOURCE_DIR}/Amalgam/packages.config
    -PackagesDirectory ${CMAKE_SOURCE_DIR}/packages
)

execute_process(
COMMAND
    powershell
    -ExecutionPolicy Bypass
    -File "${CMAKE_SOURCE_DIR}/includes.ps1"
    -sourcePath "${CMAKE_SOURCE_DIR}"
    WORKING_DIRECTORY "${CMAKE_BINARY_DIR}"
)

set(CMAKE_CXX_STANDARD 20)
add_compile_options(
    /c 
    /Zi 
    /nologo 
    /W3 
    /WX- 
    /sdl- 
    /MP 
    /O2 
    /Oi 
    /Ot 
    /GL 
    /GF 
    /Gm- 
    /EHsc 
    /MD 
    /GS- 
    /Gy 
    /fp:precise 
    /Zc:wchar_t 
    /Zc:forScope 
    /Zc:inline 
    /std:c++20 
    /permissive- 
    /external:W3 
    /Gd 
    /TP 
    /FC 
)
add_compile_definitions(
    WIN32
    NDEBUG
    _CONSOLE
    _DISABLE_CONSTEXPR_MUTEX_CONSTRUCTOR
    _WINDLL
    _MBCS
)

file(STRINGS "${CMAKE_BINARY_DIR}/srcs.txt" src_files)
file(STRINGS "${CMAKE_BINARY_DIR}/lib_roots.txt" lib_roots)
file(STRINGS "${CMAKE_BINARY_DIR}/lib_names.txt" lib_names)

link_directories(${lib_roots})

add_library(dll SHARED ${src_files})
target_compile_definitions(dll PRIVATE __CONFIGURATION__=\"$<CONFIG>\")
target_link_libraries(dll ${lib_names})
target_include_directories(
    dll
PRIVATE
    "${CMAKE_SOURCE_DIR}/Amalgam/include"
    "${CMAKE_SOURCE_DIR}/packages/boost.1.86.0/lib/native/include"
)