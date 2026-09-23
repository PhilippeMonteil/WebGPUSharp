d:
cd d:\repos\dawn

rmdir /S /Q out\win-arm64

REM génère Dawn.slnx dans \out\win-armdir *.sln64
REM qui expose diverses configurations, dont MinSizeRel ...

cmake -S . -B out/win-arm64 ^
  -G "Visual Studio 18 2026" ^
  -A ARM64 ^
  -DDAWN_FETCH_DEPENDENCIES=ON ^
  -DDAWN_BUILD_MONOLITHIC_LIBRARY=SHARED ^
  -DBUILD_SHARED_LIBS=OFF ^
  -DDAWN_ENABLE_INSTALL=ON ^
  -DDAWN_USE_BUILT_DXC=OFF ^
  -DDAWN_ENABLE_D3D12=ON ^
  -DDAWN_ENABLE_D3D11=ON ^
  -DDAWN_ENABLE_VULKAN=OFF ^
  -DDAWN_ENABLE_NULL=OFF ^
  -DDAWN_ENABLE_DESKTOP_GL=OFF ^
  -DDAWN_ENABLE_OPENGLES=OFF ^
  -DDAWN_USE_GLFW=OFF ^
  -DDAWN_BUILD_SAMPLES=OFF ^
  -DDAWN_BUILD_TESTS=OFF ^
  -DTINT_BUILD_TESTS=OFF ^
  -DTINT_BUILD_CMD_TOOLS=OFF ^
  -DDAWN_BUILD_PROTOBUF=OFF

pause

cmake --build out/win-arm64 --config Release --parallel
cmake --build out/win-arm64 --config MinSizeRel --parallel
pause

REM cmake --install out/win-arm64 --config Release --prefix install/win-arm64

