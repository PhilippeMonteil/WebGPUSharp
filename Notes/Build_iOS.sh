#!/bin/bash

cd /Users/philippemonteil/Temp/dawn

#
# device arm64
#

rm -rf build_ios_device_arm64

cmake -B build_ios_device_arm64 \
-DCMAKE_SYSTEM_NAME=iOS \
-DCMAKE_OSX_SYSROOT=iphoneos \
-DCMAKE_OSX_ARCHITECTURES=arm64 \
-DCMAKE_OSX_DEPLOYMENT_TARGET=16.0 \
-DDAWN_FETCH_DEPENDENCIES=ON \
-DDAWN_BUILD_MONOLITHIC_LIBRARY=STATIC \
-DCMAKE_BUILD_TYPE=Release \
-DBUILD_SHARED_LIBS=OFF \
-DBUILD_SAMPLES=OFF \
-DDAWN_BUILD_TESTS=OFF \
-DDAWN_ENABLE_NULL=OFF \
-DDAWN_ENABLE_OPENGLES=OFF \
-DDAWN_ENABLE_METAL=ON \
-DDAWN_ENABLE_VULKAN=OFF \
-DDAWN_USE_GLFW=OFF \
-DDAWN_BUILD_SAMPLES=OFF \
-DTINT_BUILD_TESTS=OFF \
-DTINT_BUILD_IR_BINARY=OFF \
-DDAWN_BUILD_PROTOBUF=OFF

cmake --build build_ios_device_arm64 --config Release --target webgpu_dawn

# dyld_info -exports ./build_ios_device_arm64/src/dawn/native/libwebgpu_dawn.a
find . -name "libwebgpu*.a"

# 
# ios_simulator arm64
#

rm -rf build_ios_simulator_arm64

cmake -B build_ios_simulator_arm64 \
-DCMAKE_SYSTEM_NAME=iOS \
-DCMAKE_OSX_SYSROOT=iphonesimulator \
-DCMAKE_OSX_ARCHITECTURES="arm64" \
-DCMAKE_OSX_DEPLOYMENT_TARGET=16.0 \
-DDAWN_FETCH_DEPENDENCIES=ON \
-DDAWN_BUILD_MONOLITHIC_LIBRARY=STATIC \
-DCMAKE_BUILD_TYPE=Release \
-DBUILD_SHARED_LIBS=OFF \
-DBUILD_SAMPLES=OFF \
-DDAWN_BUILD_TESTS=OFF \
-DDAWN_ENABLE_NULL=OFF \
-DDAWN_ENABLE_OPENGLES=OFF \
-DDAWN_ENABLE_METAL=ON \
-DDAWN_ENABLE_VULKAN=OFF \
-DDAWN_USE_GLFW=OFF \
-DDAWN_BUILD_SAMPLES=OFF \
-DTINT_BUILD_TESTS=OFF \
-DTINT_BUILD_IR_BINARY=OFF \
-DDAWN_BUILD_PROTOBUF=OFF

cmake --build build_ios_simulator_arm64 --config Release --target webgpu_dawn

find . -name "libwebgpu*.a"

# 
# ios_simulator x86_64
#

rm -rf build_ios_simulator_x86_64

cmake -B build_ios_simulator_x86_64 \
-DCMAKE_SYSTEM_NAME=iOS \
-DCMAKE_OSX_SYSROOT=iphonesimulator \
-DCMAKE_OSX_ARCHITECTURES="x86_64" \
-DCMAKE_OSX_DEPLOYMENT_TARGET=16.0 \
-DDAWN_FETCH_DEPENDENCIES=ON \
-DDAWN_BUILD_MONOLITHIC_LIBRARY=STATIC \
-DCMAKE_BUILD_TYPE=Release \
-DBUILD_SHARED_LIBS=OFF \
-DBUILD_SAMPLES=OFF \
-DDAWN_BUILD_TESTS=OFF \
-DDAWN_ENABLE_NULL=OFF \
-DDAWN_ENABLE_OPENGLES=OFF \
-DDAWN_ENABLE_METAL=ON \
-DDAWN_ENABLE_VULKAN=OFF \
-DDAWN_USE_GLFW=OFF \
-DDAWN_BUILD_SAMPLES=OFF \
-DTINT_BUILD_TESTS=OFF \
-DTINT_BUILD_IR_BINARY=OFF \
-DDAWN_BUILD_PROTOBUF=OFF

cmake --build build_ios_simulator_x86_64 --config Release --target webgpu_dawn

find . -name "libwebgpu*.a"

cd build_ios_simulator_x86_64
pwd
# /Users/philippemonteil/Temp/dawn/build_ios_simulator_x86_64
find . -name "webgpu.h"
# /Users/philippemonteil/Temp/dawn/build_ios_simulator_x86_64/gen/include/dawn/webgpu.h
cd ..

find . -name "libwebgpu*.a"
# /Users/philippemonteil/Temp/dawn
# /Users/philippemonteil/Temp/dawn/build_ios_simulator_arm64/src/dawn/native/libwebgpu_dawn.a
# /Users/philippemonteil/Temp/dawn/build_ios_device_arm64/src/dawn/native/libwebgpu_dawn.a
# /Users/philippemonteil/Temp/dawn/build_ios_simulator_x86_64/src/dawn/native/libwebgpu_dawn.a

cd /Users/philippemonteil/Temp/dawn

rm -rf Dawn.xcframeworks

xcodebuild -create-xcframework \
-library /Users/philippemonteil/Temp/dawn/build_ios_device_arm64/src/dawn/native/libwebgpu_dawn.a \
-headers /Users/philippemonteil/Temp/dawn/build_ios_device_arm64/gen/include/dawn/webgpu.h \
-library /Users/philippemonteil/Temp/dawn/build_ios_simulator_arm64/src/dawn/native/libwebgpu_dawn.a \
-headers /Users/philippemonteil/Temp/dawn/build_ios_simulator_arm64/gen/include/dawn/webgpu.h \
-library /Users/philippemonteil/Temp/dawn/build_ios_simulator_x86_64/src/dawn/native/libwebgpu_dawn.a \
-headers /Users/philippemonteil/Temp/dawn/build_ios_simulator_x86_64/gen/include/dawn/webgpu.h \
-output /Users/philippemonteil/Temp/dawn/Dawn.xcframeworks/libdawn_native.iOS.xcframework

