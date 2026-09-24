
# Notes sur MacOS

## x86_64

cd /Users/philippemonteil/Temp/dawn

rm -rf dawn_build_x86_64

cmake \
-B dawn_build_x86_64 \
-D CMAKE_OSX_ARCHITECTURES=x86_64 \
-D DAWN_FETCH_DEPENDENCIES=ON \
-D CMAKE_BUILD_TYPE=Release \
-D BUILD_SHARED_LIBS=OFF \
-D DAWN_BUILD_MONOLITHIC_LIBRARY=SHARED \
-D BUILD_SAMPLES=OFF \
-D DAWN_BUILD_TESTS=OFF \
-D DAWN_ENABLE_NULL=OFF \
-D DAWN_ENABLE_OPENGLES=OFF \
-D DAWN_ENABLE_METAL=ON \
-D DAWN_ENABLE_VULKAN=OFF \
-D DAWN_USE_GLFW=OFF \
-D DAWN_BUILD_SAMPLES=OFF \
-D TINT_BUILD_TESTS=OFF

cmake --build dawn_build_x86_64 --config Release --target webgpu_dawn

find . -name "libwebgpu*.dylib"
dyld_info -exports ./dawn_build_x86_64/src/dawn/native/libwebgpu_dawn.dylib
  
