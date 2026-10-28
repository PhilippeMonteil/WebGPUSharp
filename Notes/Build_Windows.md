# Notes sur la compilation de Dawn pour Windows

## Batch

````
cmake -S . -B out/win-x64 -G "Visual Studio 18 2026" -A x64 ^
  -DDAWN_FETCH_DEPENDENCIES=ON ^
  -DDAWN_BUILD_MONOLITHIC_LIBRARY=SHARED ^
  -DBUILD_SHARED_LIBS=OFF ^
  -DDAWN_ENABLE_INSTALL=OFF ^
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
````

## Notes

### Compilation de dxcompiler.dll, d3dcompiler_47.dll

Ces dlls **doivent** être jointes à la dll webgpu_dawn.dll.

### Support de D3D111 et de D3D12

### Analyse de la commande

C'est **la même commande que la première** (D3D11 activé) et la cohérence d'ensemble reste bonne : une seule `webgpu_dawn.dll`, DXC compilé, backends D3D12 et D3D11 seulement, sans outils, tests ni exemples. Voici ce que je précise ou corrige par rapport à mes réponses précédentes.

#### Ce qui est confirmé

- **`DAWN_BUILD_MONOLITHIC_LIBRARY=SHARED` + `BUILD_SHARED_LIBS=OFF`** : combinaison obligatoire, car le monolithique est refusé avec `BUILD_SHARED_LIBS=ON`. Vous obtenez `webgpu_dawn.dll` et sa bibliothèque d'import.
- **`DAWN_ENABLE_INSTALL=OFF`** : aucun paquet n'est généré, vous récupérez les fichiers à la main dans le dossier de build.
- **`DAWN_USE_BUILT_DXC=ON`** : DXC est compilé, et `dxcompiler.dll` est placée dans `out/win-x64/<Config>/`. Cette option définit aussi `DAWN_USE_BUILT_DXC` sur `dawn_native` et ses objets.
- **D3D12 `ON`** : backend principal, shaders compilés par DXC.
- **D3D11 `ON`** : backend de repli et de compatibilité, avec des shaders compilés par **FXC**.
- **Vulkan, Null, Desktop GL, OpenGL ES `OFF`**, ainsi que GLFW, exemples, tests (`DAWN_BUILD_TESTS`, `TINT_BUILD_TESTS`), `TINT_BUILD_CMD_TOOLS` et `DAWN_BUILD_PROTOBUF` : cohérent, binaire plus léger.

#### Corrections par rapport à mes réponses précédentes

**1. `dxil.dll` : plus nécessaire sur un Dawn récent.**
 Le commit `b121eff3f1da` (4 septembre 2026) a supprimé la dépendance à `dxil.dll`, car DXC signe désormais les shaders lui-même. Livrez donc `webgpu_dawn.dll` + `dxcompiler.dll`. Sur un checkout plus ancien, la DLL était copiée depuis le Windows SDK, et non compilée. Mes analyses précédentes, qui disaient de toujours la livrer, sont obsolètes pour une révision récente.

**2. Avec D3D11 activé, `d3dcompiler_47.dll` devient utile.**
 Dawn charge désormais cette DLL par chemin absolu, sauf si `DAWN_FORCE_SYSTEM_COMPONENT_LOAD` est faux, et le CMake la copie depuis le Windows SDK dans le dossier de build. C'est ce fichier que FXC utilise pour D3D11. Si vous ne la livrez pas, le backend D3D11 peut échouer à compiler ses shaders. Récupérez-la dans `out/win-x64/<Config>/` avec les autres.

**3. Le Windows SDK doit être installé.**
 La détection du SDK se fait via la variable d'environnement `WINDOWSSDKDIR` ou via le registre. La version vient de `CMAKE_VS_WINDOWS_TARGET_PLATFORM_VERSION`. Lancez la configuration depuis un « Developer Command Prompt » ou assurez-vous que le SDK est présent, sinon la copie des DLL échoue.

#### Points inchangés

- **`TINT_BUILD_IR_BINARY=OFF`** : à ajouter par cohérence avec `DAWN_BUILD_PROTOBUF=OFF`, car certaines cibles peuvent réclamer protobuf selon la révision.
- **`DAWN_DXC_ENABLE_ASSERTS_IN_NDEBUG`** : actif par défaut, DXC garde ses asserts en Release et MinSizeRel, ce qui alourdit la DLL d'environ 3,5 Mo.
- **`DAWN_FETCH_DEPENDENCIES=ON`** : nécessite Python 3 et git, et récupère aussi le code de DXC.

#### Fichiers à récupérer après le build

Dans `out/win-x64/<Config>/` :

- `webgpu_dawn.dll` et `webgpu_dawn.lib` ;
- `dxcompiler.dll` ;
- `d3dcompiler_47.dll`, car D3D11 est activé ;
- `dxil.dll` seulement si votre révision de Dawn est antérieure au 4 septembre 2026.

Les en-têtes générés se trouvent dans `out/win-x64/gen/include`, à combiner avec `include/` des sources.

Pour savoir quelle révision vous avez, lancez :

````
git merge-base --is-ancestor b121eff3f1da HEAD && echo "dxil.dll inutile"
````

## Notes sur WebGpuSharp.csproj

````
<!-- Windows x64 native library -->
<Content Include="runtimes/win-x64/native/webgpu_dawn.dll" Condition="Exists('runtimes/win-x64/native/webgpu_dawn.dll')">
	<PackagePath>runtimes/win-x64/native</PackagePath>
    <Visible>true</Visible>
    <Pack>true</Pack>
</Content>
<Content Include="runtimes/win-x64/native/d3dcompiler_47.dll" Condition="Exists('runtimes/win-x64/native/d3dcompiler_47.dll')">
	<PackagePath>runtimes/win-x64/native</PackagePath>
	<Visible>true</Visible>
	<Pack>true</Pack>
	<CopyToOutputDirectory>Always</CopyToOutputDirectory>
	<Link>d3dcompiler_47.dll</Link>
</Content>
<Content Include="runtimes/win-x64/native/dxcompiler.dll" Condition="Exists('runtimes/win-x64/native/dxcompiler.dll')">
	<PackagePath>runtimes/win-x64/native</PackagePath>
	<Visible>true</Visible>
	<Pack>true</Pack>
	<CopyToOutputDirectory>Always</CopyToOutputDirectory>
	<Link>dxcompiler.dll</Link>
</Content>
````

Les tags CopyToOutputDirectory et Link appliqués à d3dcompiler_47.dll et dxcompiler.dll
sont nécessaires pour que ces DLL soient copiées dans le dossier de sortie de l'application,
afin que l'exécutable puisse les trouver au moment de l'exécution.
