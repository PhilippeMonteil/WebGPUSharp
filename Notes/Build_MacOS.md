
# Notes sur MacOS

## Git

````
git remote -v
git branch -r
````

-> https://dawn.googlesource.com/dawn
-> origin/chromium/8074

git clone https://dawn.googlesource.com/dawn
cd dawn
git checkout chromium/8074
git checkout -b Test_25092026
git log --oneline
git branch -D Test_25092026

pwd -> /Users/philippemonteil/Temp/Test/dawn

cd /Users/philippemonteil/Temp/Test/dawn

## x86_64

cd /Users/philippemonteil/Temp/Test/dawn

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


## arm64

cd /Users/philippemonteil/Temp/dawn

rm -rf dawn_build_arm64

cmake \
-B dawn_build_arm64 \
-D CMAKE_OSX_ARCHITECTURES=arm64 \
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

cmake --build dawn_build_arm64 --config Release --target webgpu_dawn

find . -name "libwebgpu*.dylib"
dyld_info -exports ./dawn_build_arm64/src/dawn/native/libwebgpu_dawn.dylib
