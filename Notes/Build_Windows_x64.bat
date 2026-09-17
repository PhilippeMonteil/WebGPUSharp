d:
cd d:repos\dawn

rmdir /S /Q out\win-x64

cmake -S . -B out/win-x64 -G "Visual Studio 18 2026" -A x64 ^
  -DDAWN_FETCH_DEPENDENCIES=ON ^
  -DDAWN_BUILD_MONOLITHIC_LIBRARY=SHARED ^
  -DBUILD_SHARED_LIBS=OFF ^
  -DDAWN_ENABLE_INSTALL=ON ^
  -DDAWN_USE_BUILT_DXC=ON ^
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
  -DDAWN_BUILD_PROTOBUF=OFF ^
  -DTINT_BUILD_CMD_TOOLS=OFF

pause

cmake --build out/win-x64 --config Release --parallel
pause

cmake --install out/win-x64 --config Release --prefix install/win-x64
pause

