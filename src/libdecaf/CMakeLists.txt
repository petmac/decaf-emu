project(libdecaf)

include_directories(".")
include_directories("src")

file(GLOB_RECURSE CPP_SOURCE_FILES *.cpp)
file(GLOB_RECURSE HEADER_FILES *.h)

if(APPLE)
   file(GLOB_RECURSE OBJCPP_SOURCE_FILES *.mm)
else()
   set(OBJCPP_SOURCE_FILES "")
endif()

add_library(libdecaf STATIC ${CPP_SOURCE_FILES} ${OBJCPP_SOURCE_FILES} ${HEADER_FILES})
GroupSources(src)

target_link_libraries(libdecaf
    common
    libcpu
    libgfd
    libgpu
    ${ADDRLIB_LIBRARIES}
    ${CEREAL_LIBRARIES}
    ${FIXED_POINT_LIBRARIES}
    ${IMGUI_LIBRARIES}
    ${PUGIXML_LIBRARIES}
    ${ZLIB_LINK})

if(MSVC)
    target_link_libraries(libdecaf ws2_32)
    target_compile_options(libdecaf PUBLIC /wd4251)
endif()
