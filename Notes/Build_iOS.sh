#!/bin/bash

cd /Users/philippemonteil/Temp/dawn-20260922.191850

cd /Users/philippemonteil/RiderProjects/dawn
rm -rf build_ios_device_arm64
rm -rf build_ios_simulator_x86_64
rm -rf build_ios_simulator_arm64

#
# device arm64
#

cd /Users/philippemonteil/RiderProjects/dawn

rm -rf build_ios_device_arm64

cmake -B build_ios_device_arm64 -G Xcode \
  -DCMAKE_SYSTEM_NAME=iOS \
  -DCMAKE_OSX_SYSROOT=iphoneos \
  -DCMAKE_OSX_ARCHITECTURES=arm64 \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=16.0 \
  -DCMAKE_XCODE_ATTRIBUTE_CODE_SIGNING_ALLOWED=NO \
  -DCMAKE_XCODE_ATTRIBUTE_CODE_SIGNING_REQUIRED=NO \
  -DDAWN_FETCH_DEPENDENCIES=ON \
  -DDAWN_BUILD_MONOLITHIC_LIBRARY=STATIC \
  -DDAWN_ENABLE_METAL=ON \
  -DDAWN_ENABLE_VULKAN=OFF \
  -DDAWN_ENABLE_D3D11=OFF \
  -DDAWN_ENABLE_D3D12=OFF \
  -DDAWN_ENABLE_DESKTOP_GL=OFF \
  -DDAWN_ENABLE_OPENGLES=OFF \
  -DDAWN_ENABLE_NULL=OFF \
  -DDAWN_USE_GLFW=OFF \
  -DDAWN_USE_X11=OFF \
  -DDAWN_USE_WAYLAND=OFF \
  -DDAWN_BUILD_SAMPLES=OFF \
  -DDAWN_BUILD_TESTS=OFF \
  -DDAWN_BUILD_NODE_BINDINGS=OFF \
  -DDAWN_BUILD_PROTOBUF=OFF \
  -DDAWN_ENABLE_INSTALL=ON \
  -DDAWN_BUILD_PROTOBUF=OFF \
  -DDAWN_ENABLE_WIRE=OFF \
  -DTINT_BUILD_FUZZERS=OFF \
  -DTINT_BUILD_BENCHMARKS=OFF \
  -DTINT_BUILD_IR_BINARY=OFF \
  -DTINT_BUILD_CMD_TOOLS=OFF \
  -DTINT_BUILD_TESTS=OFF \
  -DTINT_BUILD_SPV_READER=OFF \
  -DTINT_BUILD_SPV_WRITER=OFF \
  -DTINT_BUILD_GLSL_WRITER=OFF \
  -DTINT_BUILD_HLSL_WRITER=OFF \
  -DTINT_BUILD_MSL_WRITER=OFF \
  -DTINT_BUILD_WGSL_READER=OFF \
  -DTINT_BUILD_WGSL_WRITER=OFF

cmake --build build_ios_device_arm64 --config Release --parallel

cd build_ios_device_arm64
find . -name "*.a" ! -name "libdawn_monolithic.a" > libs.txt
xcrun libtool -static -o libdawn_monolithic.device_arm64.a $(cat libs.txt)
cd ..

# 
# ios_simulator x86_64
#

cd /Users/philippemonteil/RiderProjects/dawn

rm -rf build_ios_simulator_x86_64

cmake -B build_ios_simulator_x86_64 -G Xcode \
-DCMAKE_SYSTEM_NAME=iOS \
-DCMAKE_OSX_SYSROOT=iphonesimulator \
-DCMAKE_OSX_ARCHITECTURES="x86_64" \
-DCMAKE_OSX_DEPLOYMENT_TARGET=16.0 \
-DCMAKE_XCODE_ATTRIBUTE_CODE_SIGNING_ALLOWED=NO \
-DDAWN_FETCH_DEPENDENCIES=ON \
-DDAWN_ENABLE_METAL=ON \
-DDAWN_ENABLE_VULKAN=OFF \
-DDAWN_ENABLE_D3D11=OFF \
-DDAWN_ENABLE_D3D12=OFF \
-DDAWN_ENABLE_DESKTOP_GL=OFF \
-DDAWN_ENABLE_OPENGLES=OFF \
-DDAWN_ENABLE_NULL=OFF \
-DDAWN_USE_GLFW=OFF \
-DDAWN_USE_X11=OFF \
-DDAWN_USE_WAYLAND=OFF \
-DDAWN_BUILD_SAMPLES=OFF \
-DDAWN_BUILD_TESTS=OFF \
-DDAWN_BUILD_NODE_BINDINGS=OFF \
-DDAWN_BUILD_PROTOBUF=OFF \
-DDAWN_ENABLE_INSTALL=ON \
-DDAWN_BUILD_MONOLITHIC_LIBRARY=STATIC \
-DDAWN_BUILD_PROTOBUF=OFF \
-DTINT_BUILD_FUZZERS=OFF \
-DTINT_BUILD_BENCHMARKS=OFF \
-DTINT_BUILD_IR_BINARY=OFF \
-DTINT_BUILD_CMD_TOOLS=OFF \
-DTINT_BUILD_TESTS=OFF \
-DTINT_BUILD_SPV_READER=OFF \
-DTINT_BUILD_SPV_WRITER=OFF \
-DTINT_BUILD_GLSL_WRITER=OFF \
-DTINT_BUILD_HLSL_WRITER=OFF \
-DTINT_BUILD_MSL_WRITER=OFF \
-DTINT_BUILD_WGSL_READER=OFF \
-DTINT_BUILD_WGSL_WRITER=OFF

cmake --build build_ios_simulator_x86_64 --config Release --parallel

cd build_ios_simulator_x86_64
find . -name "*.a" ! -name "libdawn_monolithic.simulator_x86_64.a" > libs.txt
xcrun libtool -static -o libdawn_monolithic.simulator_x86_64.a $(cat libs.txt)
cd ..

# 
# ios_simulator arm64
#

cd /Users/philippemonteil/RiderProjects/dawn

rm -rf build_ios_simulator_arm64

cmake -B build_ios_simulator_arm64 -G Xcode \
-DCMAKE_SYSTEM_NAME=iOS \
-DCMAKE_OSX_SYSROOT=iphonesimulator \
-DCMAKE_OSX_ARCHITECTURES="arm64" \
-DCMAKE_OSX_DEPLOYMENT_TARGET=16.0 \
-DCMAKE_XCODE_ATTRIBUTE_CODE_SIGNING_ALLOWED=NO \
-DDAWN_FETCH_DEPENDENCIES=ON \
-DDAWN_ENABLE_METAL=ON \
-DDAWN_ENABLE_VULKAN=OFF \
-DDAWN_ENABLE_D3D11=OFF \
-DDAWN_ENABLE_D3D12=OFF \
-DDAWN_ENABLE_DESKTOP_GL=OFF \
-DDAWN_ENABLE_OPENGLES=OFF \
-DDAWN_ENABLE_NULL=OFF \
-DDAWN_USE_GLFW=OFF \
-DDAWN_USE_X11=OFF \
-DDAWN_USE_WAYLAND=OFF \
-DDAWN_BUILD_SAMPLES=OFF \
-DDAWN_BUILD_TESTS=OFF \
-DDAWN_BUILD_NODE_BINDINGS=OFF \
-DDAWN_BUILD_PROTOBUF=OFF \
-DDAWN_ENABLE_INSTALL=ON \
-DDAWN_BUILD_MONOLITHIC_LIBRARY=STATIC \
-DDAWN_BUILD_PROTOBUF=OFF \
-DTINT_BUILD_FUZZERS=OFF \
-DTINT_BUILD_BENCHMARKS=OFF \
-DTINT_BUILD_IR_BINARY=OFF \
-DTINT_BUILD_CMD_TOOLS=OFF \
-DTINT_BUILD_TESTS=OFF \
-DTINT_BUILD_SPV_READER=OFF \
-DTINT_BUILD_SPV_WRITER=OFF \
-DTINT_BUILD_GLSL_WRITER=OFF \
-DTINT_BUILD_HLSL_WRITER=OFF \
-DTINT_BUILD_MSL_WRITER=OFF \
-DTINT_BUILD_WGSL_READER=OFF \
-DTINT_BUILD_WGSL_WRITER=OFF

cmake --build build_ios_simulator_arm64 --config Release --parallel

cd /Users/philippemonteil/RiderProjects/dawn
cd build_ios_simulator_arm64

rm libs.txt
find . -name "libdawn_native.a" >> libs.txt
find . -name "libdawn_platform.a" >> libs.txt
find . -name "libdawn_common.a" >> libs.txt
find . -name "libdawn_proc.a" >> libs.txt
find . -name "libtint_*.a" >> libs.txt
find . -name "libabsl_*.a" >> libs.txt

rm libdawn_monolithic.simulator_arm64.a
xcrun libtool -static -o libdawn_monolithic.simulator_arm64.a $(cat libs.txt)
ls -l libdawn_monolithic.*.a

cd ..


libdawn_monolithic.simulator_arm64.a

nm -gU /Users/philippemonteil/RiderProjects/dawn/build_ios_simulator_arm64/libdawn_monolithic.simulator_arm64.a 2>/dev/null | grep -c “tint” # objets Tint présents ?
nm -gU /Users/philippemonteil/RiderProjects/dawn/build_ios_simulator_arm64/libdawn_monolithic.simulator_arm64.a 2>/dev/null | grep -c “absl” # objets abseil présents ?

# /Users/philippemonteil/RiderProjects/dawn/build_ios_simulator_arm64/libdawn_monolithic.simulator_arm64.a
# /Users/philippemonteil/RiderProjects/dawn/build_ios_device_arm64/libdawn_monolithic.device_arm64.a
# /Users/philippemonteil/RiderProjects/dawn/build_ios_simulator_x86_64/libdawn_monolithic.simulator_x86_64.a

# rm -rf /Users/philippemonteil/RiderProjects/dawn/Dawn.xcframeworks/libdawn_native.iOS.xcframework

# xcodebuild -create-xcframework \
# -library /Users/philippemonteil/RiderProjects/dawn/build_ios_simulator_arm64/libdawn_monolithic.simulator_arm64.a \
# -headers /Users/philippemonteil/RiderProjects/dawn/build_ios_simulator_arm64/gen/webgpu-headers \
# -library /Users/philippemonteil/RiderProjects/dawn/build_ios_device_arm64/libdawn_monolithic.device_arm64.a \
# -headers /Users/philippemonteil/RiderProjects/dawn/build_ios_device_arm64/gen/webgpu-headers \
# -library /Users/philippemonteil/RiderProjects/dawn/build_ios_simulator_x86_64/libdawn_monolithic.simulator_x86_64.a \
# -headers /Users/philippemonteil/RiderProjects/dawn/build_ios_simulator_x86_64/gen/webgpu-headers \
# -output /Users/philippemonteil/RiderProjects/dawn/Dawn.xcframeworks/libdawn_native.iOS.xcframework

nm ./src/dawn/Release-iphonesimulator/libdawn_proc.a | grep LogMessage
