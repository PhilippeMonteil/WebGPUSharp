
// 21/09/2026 17:39

rm -rf /Users/philippemonteil/RiderProjects/dawn/Dawn.xcframeworks/Dawn.iOS.xcframework

rm -rf build_ios_device

cmake -B build_ios_device -G Xcode \
  -DCMAKE_SYSTEM_NAME=iOS \
  -DCMAKE_OSX_SYSROOT=iphoneos \
  -DCMAKE_OSX_ARCHITECTURES=arm64 \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=14.0 \
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
  -DTINT_BUILD_MSL_WRITER=ON \
  -DTINT_BUILD_WGSL_READER=ON \
  -DTINT_BUILD_WGSL_WRITER=ON

cmake --build build_ios_device --config Release --parallel

pwd -> /Users/philippemonteil/RiderProjects/dawn
find . -name "libdawn_native.a" -> /Users/philippemonteil/RiderProjects/dawn/build_ios_device/src/dawn/native/Release-iphoneos/libdawn_native.a
find . -name "libdawn_proc.a" -> /Users/philippemonteil/RiderProjects/dawn/build_ios_device/src/dawn/Release-iphoneos/libdawn_proc.a

libtool -static \
  -o /Users/philippemonteil/RiderProjects/dawn/build_ios_device/src/dawn/native/Release-iphoneos/libdawn_combined.a \
  /Users/philippemonteil/RiderProjects/dawn/build_ios_device/src/dawn/native/Release-iphoneos/libdawn_native.a \
  /Users/philippemonteil/RiderProjects/dawn/build_ios_device/src/dawn/Release-iphoneos/libdawn_proc.a

find . -name "libdawn_combined.a" 
-> /Users/philippemonteil/RiderProjects/dawn/build_ios_device/src/dawn/native/Release-iphoneos/libdawn_combined.a

rm -rf build_ios_simulator

cmake -B build_ios_simulator -G Xcode \
  -DCMAKE_SYSTEM_NAME=iOS \
  -DCMAKE_OSX_SYSROOT=iphonesimulator \
  -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=14.0 \
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
  -DTINT_BUILD_MSL_WRITER=ON \
  -DTINT_BUILD_WGSL_READER=ON \
  -DTINT_BUILD_WGSL_WRITER=ON

cmake --build build_ios_simulator --config Release --parallel

pwd -> /Users/philippemonteil/RiderProjects/dawn
find . -name "libdawn_native.a" 
find . -name "libdawn_proc.a"

./build_ios_simulator/src/dawn/native/Release-iphonesimulator/libdawn_native.a
./build_ios_device/src/dawn/native/Release-iphoneos/libdawn_native.a

./build_ios_simulator/src/dawn/Release-iphonesimulator/libdawn_proc.a
./build_ios_device/src/dawn/Release-iphoneos/libdawn_proc.a

libtool -static \
  -o /Users/philippemonteil/RiderProjects/dawn/build_ios_simulator/src/dawn/native/Release-iphonesimulator/libdawn_combined.a \
  /Users/philippemonteil/RiderProjects/dawn/build_ios_simulator/src/dawn/native/Release-iphonesimulator/libdawn_native.a \
  /Users/philippemonteil/RiderProjects/dawn/build_ios_device/src/dawn/Release-iphoneos/libdawn_proc.a

find . -name "webgpu*.h"

./build_ios_simulator/gen/include/dawn/webgpu.h
./build_ios_simulator/gen/webgpu-headers/webgpu.h
./build_ios_device/gen/include/dawn/webgpu.h
./build_ios_device/gen/webgpu-headers/webgpu.h

xcodebuild -create-xcframework \
  -library /Users/philippemonteil/RiderProjects/dawn/build_ios_simulator/src/dawn/native/Release-iphonesimulator/libdawn_native.a \
  -headers /Users/philippemonteil/RiderProjects/dawn/build_ios_simulator/gen/webgpu-headers \
  -library /Users/philippemonteil/RiderProjects/dawn/build_ios_device/src/dawn/native/Release-iphoneos/libdawn_native.a \
  -headers /Users/philippemonteil/RiderProjects/dawn/build_ios_device/gen/webgpu-headers \
  -output /Users/philippemonteil/RiderProjects/dawn/Dawn.xcframeworks/libdawn_native.iOS.xcframework

find . -name "libdawn_native.iOS.xcframework"

xcodebuild -create-xcframework \
  -library /Users/philippemonteil/RiderProjects/dawn/build_ios_simulator/src/dawn/Release-iphonesimulator/libdawn_proc.a \
  -headers /Users/philippemonteil/RiderProjects/dawn/build_ios_simulator/gen/webgpu-headers \
  -library /Users/philippemonteil/RiderProjects/dawn/build_ios_device/src/dawn/Release-iphoneos/libdawn_proc.a \
  -headers /Users/philippemonteil/RiderProjects/dawn/build_ios_device/gen/webgpu-headers \
  -output /Users/philippemonteil/RiderProjects/dawn/Dawn.xcframeworks/libdawn_proc.iOS.xcframework

find . -name "libdawn_proc.iOS.xcframework"

find . -name "libdawn_*.a"


<ItemGroup Condition="'$(TargetFramework)' == 'net8.0-ios' or '$(TargetFramework)' == 'net9.0-ios'">
    
    <!-- 1. Dawn Proc (celle qui générait l'erreur) -->
    <NativeReference Include="Platforms\iOS\libs\libdawn_proc.a">
        <Kind>Static</Kind>
        <SmartLink>True</SmartLink>
    </NativeReference>

    <!-- 2. Les dépendances de Dawn (Native, Platform, Common) -->
    <NativeReference Include="Platforms\iOS\libs\libdawn_native.a">
        <Kind>Static</Kind>
        <SmartLink>True</SmartLink>
    </NativeReference>

    <NativeReference Include="Platforms\iOS\libs\libdawn_platform.a">
        <Kind>Static</Kind>
        <SmartLink>True</SmartLink>
    </NativeReference>

    <NativeReference Include="Platforms\iOS\libs\libdawn_common.a">
        <Kind>Static</Kind>
        <SmartLink>True</SmartLink>
    </NativeReference>

</ItemGroup>

<ItemGroup Condition="'$(TargetFramework.Contains(-ios))' and '$(RuntimeIdentifier)' == 'ios-arm64'">

    <!-- Frameworks Apple requis pour Dawn Native -->
    <NativeReference Include="Platforms\iOS\libs\ios-arm64\libdawn_native.a" Kind="Static" SmartLink="True">
        <!-- On injecte ici les dépendances matérielles d'iOS exigées par Dawn -->
        <Frameworks>Metal QuartzCore Foundation CoreGraphics CoreFoundation</Frameworks>
    </NativeReference>

    <!-- Les autres briques de Dawn -->
    <NativeReference Include="Platforms\iOS\libs\ios-arm64\libdawn_proc.a" Kind="Static" SmartLink="True" />
    <NativeReference Include="Platforms\iOS\libs\ios-arm64\libdawn_platform.a" Kind="Static" SmartLink="True" />
    <NativeReference Include="Platforms\iOS\libs\ios-arm64\libdawn_common.a" Kind="Static" SmartLink="True" />
    
    <!-- Ne pas oublier Tint (générateur de Shaders indispensable à Dawn) -->
    <NativeReference Include="Platforms\iOS\libs\ios-arm64\libtint.a" Kind="Static" SmartLink="True" />

</ItemGroup>

