
# Notes sur MacOS

## A) sur MacOS, comment produire un fichier .dynlib à partir d'un .xcframework ?

````
cd /Users/philippemonteil/Temp
clang++ -dynamiclib \
  -arch arm64 -arch x86_64 \
  -mmacosx-version-min=12.0 \
  -Wl,-force_load,dawn-apple.xcframework/macos-arm64_x86_64/libwebgpu_dawn.a \
  -framework Metal -framework QuartzCore -framework Foundation \
  -framework IOSurface -framework CoreGraphics -framework IOKit \
  -install_name @rpath/libwebgpu_dawn.dylib \
  -o libwebgpu_dawn.dylib
lipo -info libwebgpu_dawn.dylib
````

### D'abord : inspecter le contenu

Tout dépend de ce que contient le `.xcframework`. Il n'y a pas de conversion universelle.

bash

```bash
plutil -p Dawn.xcframework/Info.plist
ls -R Dawn.xcframework | head -40
find Dawn.xcframework \( -name '*.a' -o -name '*.dylib' -o -name '*.framework' \)
```

Trois cas de figure se présentent.

### Cas 1 : il contient déjà du dynamique

Si vous voyez des `.framework` ou des `.dylib`, il n'y a rien à produire : extrayez le binaire.

bash

```bash
SLICE=Dawn.xcframework/macos-arm64_x86_64

# framework dynamique : le binaire est à la racine, sans extension
cp $SLICE/WebGPUDawn.framework/Versions/A/WebGPUDawn ./libwebgpu_dawn.dylib

file libwebgpu_dawn.dylib          # doit dire "dynamically linked shared library"
install_name_tool -id @rpath/libwebgpu_dawn.dylib libwebgpu_dawn.dylib
```

Vérifiez bien avec `file` : un binaire de framework peut être statique, auquel cas vous êtes en réalité dans le cas 2.

### Cas 2 : il contient des `.a` (le cas de Dawn)

C'est votre situation, puisque le `dawn-apple-*.xcframework` officiel embarque `libwebgpu_dawn.a`. Il n'existe **pas** d'outil qui convertit une archive statique en dylib : il faut refaire une édition de liens.

bash

```bash
SLICE=Dawn.xcframework/macos-arm64_x86_64
AR=$SLICE/libwebgpu_dawn.a

clang++ -dynamiclib \
  -arch arm64 -arch x86_64 \
  -mmacosx-version-min=12.0 \
  -Wl,-force_load,"$AR" \
  -framework Metal -framework QuartzCore -framework Foundation \
  -framework IOSurface -framework CoreGraphics \
  -lc++ \
  -install_name @rpath/libwebgpu_dawn.dylib \
  -o libwebgpu_dawn.dylib
```

Le `-force_load` est indispensable, et pour la même raison que dans vos wrappers Android et MAUI : sans référence externe, le linker ne tirerait quasiment rien de l'archive et produirait une dylib vide. C'est l'équivalent Mach-O de `--whole-archive`.

Les `-arch` doubles ne fonctionnent que si la tranche du xcframework est elle-même universelle. Si les architectures sont dans des tranches séparées, traitez-les une par une puis fusionnez avec `lipo -create`.

### Cas 3 : plusieurs `.a` dans la tranche

Si la tranche contient des archives séparées (Tint, abseil à part), il faut toutes les passer, chacune avec son propre `-force_load` :

bash

```bash
FORCE=""
for a in $SLICE/*.a; do FORCE="$FORCE -Wl,-force_load,$a"; done
clang++ -dynamiclib $FORCE ... -o libwebgpu_dawn.dylib
```

### Réduire la table d'exports

Une fois la dylib produite, elle exporte tout Tint et abseil. Comme vu précédemment, c'est le moment d'en profiter :

bash

```bash
nm -gU libwebgpu_dawn.dylib | awk '/ T _wgpu/ {print $3}' | sort -u > exports.txt
```

Puis relancez le lien en ajoutant `-Wl,-exported_symbols_list,exports.txt`.

### Vérifier

bash

```bash
file libwebgpu_dawn.dylib
lipo -info libwebgpu_dawn.dylib
otool -L libwebgpu_dawn.dylib | head -5      # l'install_name doit être @rpath/...
nm -gU libwebgpu_dawn.dylib | grep wgpuCreateInstance
```

Si la dernière commande ne renvoie rien alors que le lien a réussi, c'est le `-force_load` qui manque ou qui pointe sur la mauvaise archive.

### Une remarque

Si vous contrôlez la source, recompiler Dawn directement en `SHARED` avec CMake, comme dans ma réponse précédente, donne un meilleur résultat que ce relink : le linker dispose alors de toute l'information de visibilité et des dépendances, là où `-force_load` sur une archive opaque embarque tout sans discernement. La reconstruction à partir du `.xcframework` est surtout utile quand vous n'avez que le binaire.

## B) ...

// 20/09/2026 18:35

// Reference the native library / iOS

<ItemGroup Condition="$(TargetFramework.Contains('-ios'))">
  <NativeReference Include="../native/Dawn.xcframework">
    <Kind>Static</Kind>
    <ForceLoad>True</ForceLoad>
    <SmartLink>False</SmartLink>
    <Frameworks>Metal MetalKit QuartzCore Foundation</Frameworks>
    <LinkerFlags>-lc++</LinkerFlags>
  </NativeReference>
</ItemGroup>

ForceLoad is what stops the linker discarding Dawn's object files since nothing in managed code visibly calls them at link time. 
-lc++ is needed because Dawn is C++ under the hood even though webgpu.h is a plain C surface. 
Since your archive is static, there's no code-signing step at all — it links straight into the app binary.

// Bind the C API / iOS

Static libs resolve through __Internal:

using System.Runtime.InteropServices;

internal static partial class Dawn
{
    const string Lib = "__Internal";

    [LibraryImport(Lib, EntryPoint = "wgpuCreateInstance")]
    internal static partial IntPtr CreateInstance(IntPtr descriptor);
    
    [LibraryImport(Lib, EntryPoint = "wgpuInstanceRelease")]
    internal static partial void InstanceRelease(IntPtr instance);
}

//
// ios : xcframework
//

rm -rf /Users/philippemonteil/RiderProjects/dawn/Dawn.xcframeworks/Dawn.iOS.xcframework

xcodebuild -create-xcframework \
  -library /Users/philippemonteil/RiderProjects/dawn/build_ios_simulator/src/dawn/native/Release-iphonesimulator/libdawn_native.a \
  -headers /Users/philippemonteil/RiderProjects/dawn/build_ios_simulator/gen/webgpu-headers \
  -library /Users/philippemonteil/RiderProjects/dawn/build_ios_device/src/dawn/native/Release-iphoneos/libdawn_native.a \
  -headers /Users/philippemonteil/RiderProjects/dawn/build_ios_device/gen/webgpu-headers \
  -output /Users/philippemonteil/RiderProjects/dawn/Dawn.xcframeworks/Dawn.iOS.xcframework

nm -gU /Users/philippemonteil/RiderProjects/dawn/build_ios_simulator/src/dawn/native/Release-iphonesimulator/libdawn_native.a
objdump --syms /Users/philippemonteil/RiderProjects/dawn/build_ios_simulator/src/dawn/native/Release-iphonesimulator/libdawn_native.a

//
// macos : xcframework
//

rm -rf ./Dawn.xcframeworks/Dawn.macOS.xcframework

xcodebuild -create-xcframework \
  -library /Users/philippemonteil/RiderProjects/dawn/build_macos/src/dawn/native/Release/libdawn_native.a \
  -headers /Users/philippemonteil/RiderProjects/dawn/build_macos/gen/webgpu-headers/webgpu.h \
  -output ./Dawn.xcframeworks/Dawn.macOS.xcframework

./build_macos/gen/webgpu-headers/webgpu.h

//
// macos
//

rm -rf build_macos

cmake -B build_macos -G Xcode \
  -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=12.0 \
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
  -DDAWN_BUILD_MONOLITHIC_LIBRARY=SHARED \
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

cmake --build build_macos --config Release

find . -name "libdawn_native.*"

./build_macos/build/dawn_native.build/Release/Objects-normal/arm64/Binary/libdawn_native.a // 6 Mb
./build_macos/build/dawn_native.build/Release/Objects-normal/x86_64/Binary/libdawn_native.a // 6 Mb
./build_macos/src/dawn/native/Release/libdawn_native.a // 12 Mb

find . -name "webgpu.h"

./build_macos/gen/webgpu-headers/webgpu.h

//
// iphoneos arm64
//
// - TINT_BUILD_WGSL_READER=ON, TINT_BUILD_WGSL_WRITER=ON : incluent Tint dans les .a produits
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

cmake --build build_ios_device --config Release

find . -name "libdawn_native.a"

/Users/philippemonteil/RiderProjects/dawn/build_ios_device/src/dawn/native/Release-iphoneos/libdawn_native.a

//
// iphoneos similator
//

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

cmake --build build_ios_simulator --config Release

find . -name "libdawn_native.a"

./build/dawn_native.build/Release-iphonesimulator/Objects-normal/arm64/Binary/libdawn_native.a
./build/dawn_native.build/Release-iphonesimulator/Objects-normal/x86_64/Binary/libdawn_native.a
./src/dawn/native/Release-iphonesimulator/libdawn_native.a

find . -name "webgpu.h"

./build_ios_simulator/gen/webgpu-headers/webgpu.h
./build_ios_device/gen/webgpu-headers/webgpu.h
