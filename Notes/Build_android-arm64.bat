D:
cd D:\Repos\dawn

REM doit contenir \prebuilt\windows-x86_64\bin\ninja.exe : cf CMAKE_MAKE_PROGRAM
set NDK=C:\Android\android-ndk-r30-windows\android-ndk-r30

REM ANDROID_ABI=arm64-v8a;x86_64

rmdir /S /Q out\android-arm64

cmake -S . -B out\android-arm64 -G Ninja ^
  -DCMAKE_TOOLCHAIN_FILE=%NDK%\build\cmake\android.toolchain.cmake ^
  -DCMAKE_MAKE_PROGRAM=%NDK%\prebuilt\windows-x86_64\bin\ninja.exe ^
  -DANDROID_ABI=arm64-v8a ^
  -DANDROID_PLATFORM=android-28 ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DCMAKE_VISIBILITY_INLINES_HIDDEN=ON ^
  -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=MinSizeRel ^
  -DDAWN_ENABLE_VULKAN=ON ^
  -DDAWN_ENABLE_OPENGLES=OFF ^
  -DDAWN_ENABLE_D3D11=OFF ^
  -DDAWN_ENABLE_D3D12=OFF ^
  -DDAWN_ENABLE_METAL=OFF ^
  -DDAWN_ENABLE_DESKTOP_GL=OFF ^
  -DDAWN_ENABLE_NULL=OFF ^
  -DDAWN_USE_X11=OFF ^
  -DDAWN_USE_WAYLAND=OFF ^
  -DDAWN_USE_GLFW=OFF ^
  -DDAWN_BUILD_SAMPLES=OFF ^
  -DDAWN_BUILD_ANDROID_SAMPLES=OFF ^
  -DTINT_BUILD_TESTS=OFF ^
  -DTINT_BUILD_CMD_TOOLS=OFF ^
  -DTINT_BUILD_SPV_READER=OFF ^
  -DTINT_BUILD_IR_BINARY=OFF ^
  -DTINT_BUILD_GLSL_VALIDATOR=OFF ^
  -DTINT_BUILD_GLSL_WRITER=OFF ^
  -DTINT_BUILD_GLSL_READER=OFF ^
  -DDAWN_BUILD_MONOLITHIC_LIBRARY=SHARED ^
  -DDAWN_BUILD_PROTOBUF=OFF
  
cmake --build out\android-arm64

pause
d:
cd D:\Repos\dawn\out\android-arm64\src\dawn\native
dir libwebgpu_dawn.so
llvm-strip --strip-all D:\Repos\dawn\out\android-arm64\src\dawn\native\libwebgpu_dawn.so -o D:\Repos\dawn\out\android-arm64\src\dawn\native\webgpu_dawn.so 
dir webgpu_dawn.so
cd D:\Repos\dawn
pause
