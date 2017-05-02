project(libgpu)

include_directories(".")
include_directories("src")

file(GLOB_RECURSE SOURCE_FILES *.cpp)
file(GLOB_RECURSE HEADER_FILES *.h)
file(GLOB_RECURSE INLINE_FILES *.inl)

if(APPLE)
    file(GLOB_RECURSE OBJCPP_FILES *.mm)
else()
    set(OBJCPP_FILES "")
endif()

add_library(libgpu STATIC ${SOURCE_FILES} ${HEADER_FILES} ${INLINE_FILES} ${OBJCPP_FILES})
GroupSources(latte)
GroupSources(src)

target_link_libraries(libgpu
    common
    libcpu
    ${ADDRLIB_LIBRARIES})

if(DECAF_GL)
    target_link_libraries(libgpu
        ${GLBINDING_LIBRARIES}
        ${OPENGL_LIBRARIES})

   if(MSVC)
       # GLbinding linker warning
       target_compile_options(libgpu PUBLIC /wd4251)
   endif()
endif()

if(DECAF_VULKAN)
    target_link_libraries(libgpu
        ${VULKAN_LIBRARIES})
endif()

if(DECAF_METAL)
    target_link_libraries(libgpu
        ${COREGRAPHICS_LIBRARIES}
        ${METAL_LIBRARIES}
        ${METALKIT_LIBRARIES})
endif()
