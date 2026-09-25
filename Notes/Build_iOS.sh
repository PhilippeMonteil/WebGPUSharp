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
# ios_simulator arm64;x86_64
#

rm -rf build_ios_simulator

cmake -B build_ios_simulator \
-DCMAKE_SYSTEM_NAME=iOS \
-DCMAKE_OSX_SYSROOT=iphonesimulator \
-DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
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

cmake --build build_ios_simulator --config Release --target webgpu_dawn

find . -name "libwebgpu*.a"


cd /Users/philippemonteil/Temp/dawn

rm -rf Dawn.xcframeworks

#./build_ios_simulator/src/dawn/native/libwebgpu_dawn.a
#./build_ios_device_arm64/src/dawn/native/libwebgpu_dawn.a

xcodebuild -create-xcframework \
-library /Users/philippemonteil/Temp/dawn/build_ios_device_arm64/src/dawn/native/libwebgpu_dawn.a \
-headers /Users/philippemonteil/Temp/dawn/build_ios_device_arm64/gen/include/dawn/webgpu.h \
-library /Users/philippemonteil/Temp/dawn/build_ios_simulator/src/dawn/native/libwebgpu_dawn.a \
-headers /Users/philippemonteil/Temp/dawn/build_ios_simulator/gen/include/dawn/webgpu.h \
-output /Users/philippemonteil/Temp/dawn/Dawn.xcframeworks/libwebgpu_dawn.iOS.xcframework

ls -l /Users/philippemonteil/Temp/dawn/Dawn.xcframeworks/libwebgpu_dawn.iOS.xcframework
