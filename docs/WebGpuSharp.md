# WebGpuSharp

## github

https://github.com/PhilippeMonteil/WebGPUSharp

## WebGPU_FFI

Projection C# des points d'entrée de l'API WebGPU

## WebGpuSafeHandle, WebGpuSafeHandle<THandle>

WebGpuSafeHandle<THandle> encapsule une instance de <THandle> dans une classe IDisposable
et dotée d'un Finalizer.

````
public abstract class WebGpuSafeHandle : IDisposable
{

public sealed class WebGpuSafeHandle<THandle> : WebGpuSafeHandle
    where THandle : unmanaged, IWebGpuHandle<THandle>
{
    private THandle _handle;

    public WebGpuSafeHandle(THandle handle)
    {
        _handle = handle;
        IncrementTotalActiveHandles();
        WebGpuSafeHandleCountStore<THandle>.IncrementActiveHandles();
    }

````

Sa méthode Dispose et son Finalizer appellent :

````
    THandle.Release(THandle.UnsafeFromPointer(handleValue));
````

## IWebGpuHandle<THandle>

````
public interface IWebGpuHandle<TSelf>
    where TSelf : unmanaged, IWebGpuHandle<TSelf>
{
    public static abstract ref UIntPtr AsPointer(ref TSelf handle);
    public static abstract TSelf Null { get; }
    public static abstract bool IsNull(TSelf handle);
    public static abstract TSelf UnsafeFromPointer(UIntPtr pointer);
    public static abstract void Reference(TSelf handle);
    public static abstract void Release(TSelf handle);
}
````

## WebGPUManagedHandleBase<THandle>

Classe abstraite encapsulant un <THandle> dans un WebGpuSafeHandle<THandle>.

````
public abstract class WebGPUManagedHandleBase<THandle> :
    IEquatable<WebGPUManagedHandleBase<THandle>>,
    IEquatable<THandle>
    where THandle : unmanaged, IEquatable<THandle>, IWebGpuHandle<THandle>
{
    private readonly WebGpuSafeHandle<THandle> _safeHandle;

    protected WebGPUManagedHandleBase(THandle handle)
    {
        _safeHandle = new WebGpuSafeHandle<THandle>(handle);
    }
````

### Exemple de classe dérivée : Device

Device dérive de WebGPUManagedHandleBase<DeviceHandle> et encapsule une instance de Instance.

````
public sealed class Device :
    WebGPUManagedHandleBase<DeviceHandle>,
    IFromHandleWithInstance<Device, DeviceHandle>
{

    private readonly Instance _instance;

    private Device(DeviceHandle handle, Instance instance) : base(handle)
    {
        _instance = instance;
    }

````

Device expose IFromHandleWithInstance<Device, DeviceHandle> et donc les méthodes :

````
static Device? IFromHandleWithInstance<Device, DeviceHandle>.FromHandle(DeviceHandle managedHandle, Instance instance)
static Instance IFromHandleWithInstance<Device, DeviceHandle>.GetOwnerInstance(Device managedHandle)
````

Device peut ainsi faire l'objet d'un appel de WebGPUMarshal.ToSafeHandle en tant que type <TSafeHandle>

````
    public static TSafeHandle? ToSafeHandle<TSafeHandle, THandle>(THandle handle, Instance instance)
        where TSafeHandle : IFromHandleWithInstance<TSafeHandle, THandle>
        where THandle : unmanaged, IWebGpuHandle<THandle>
    {
        return TSafeHandle.FromHandle(handle, instance);
    }
````

comme par DeviceHandle.ToSafeHandle

````
public unsafe readonly partial struct DeviceHandle :
    IDisposable,
    IWebGpuHandleNeedInstance<DeviceHandle, Device>
{

    public Device? ToSafeHandle(Instance instance) => ToSafeHandle<Device, DeviceHandle>(this, instance);
    
````

## DeviceHandle / Device

### DeviceHandle

````
public unsafe readonly partial struct DeviceHandle :
    IDisposable,
    IWebGpuHandleNeedInstance<DeviceHandle, Device>
{
````

La partial struct est définie dans deux sources :

````
gen/DeviceHandle.cs
src/ffi/DeviceHandle.cs
````

les méthodes exposées par DeviceHandle se trouvant dans gen/DeviceHandle.cs
appellent les méthodes correspondantes exposées par WebGPU_FFI :

gen/DeviceHandle.cs :

````
    public TextureHandle CreateTexture(TextureDescriptorFFI* descriptor) 
        => WebGPU_FFI.DeviceCreateTexture(this, descriptor); // gen````
````

les méthodes exposées par DeviceHandle se trouvant dans src/ffi/DeviceHandle.cs
appellent également les méthodes correspondantes exposées par WebGPU_FFI,
à partir de paramètres C# et non plus de pointeurs comme celles de gen/DeviceHandle.cs:

\src\ffi\DeviceHandle.cs

````
public unsafe readonly partial struct DeviceHandle :
    IDisposable,
    IWebGpuHandleNeedInstance<DeviceHandle, Device>
{

    public TextureHandle CreateTexture(ref TextureDescriptor textureDescriptor)
    	...
        return WebGPU_FFI.DeviceCreateTexture(this, textureDescriptorPtr);


    public TextureHandle CreateTexture(TextureDescriptor textureDescriptor)
    	...
        return WebGPU_FFI.DeviceCreateTexture(this, &textureDescriptor._unmanagedDescriptor);

````

gen/WebGPU_FFI.cs :

méthodes portant sur DeviceHandle :

````
public static extern BindGroupHandle DeviceCreateBindGroup(DeviceHandle device, BindGroupDescriptorFFI* descriptor);
public static extern BindGroupLayoutHandle DeviceCreateBindGroupLayout(DeviceHandle device, BindGroupLayoutDescriptorFFI* descriptor);
public static extern BufferHandle DeviceCreateBuffer(DeviceHandle device, BufferDescriptorFFI* descriptor);
public static extern CommandEncoderHandle DeviceCreateCommandEncoder(DeviceHandle device, CommandEncoderDescriptorFFI* descriptor);
public static extern ComputePipelineHandle DeviceCreateComputePipeline(DeviceHandle device, ComputePipelineDescriptorFFI* descriptor);
public static extern Future DeviceCreateComputePipelineAsync(DeviceHandle device, ComputePipelineDescriptorFFI* descriptor, CreateComputePipelineAsyncCallbackInfoFFI callbackInfo);
public static extern PipelineLayoutHandle DeviceCreatePipelineLayout(DeviceHandle device, PipelineLayoutDescriptorFFI* descriptor);
public static extern QuerySetHandle DeviceCreateQuerySet(DeviceHandle device, QuerySetDescriptorFFI* descriptor);
public static extern RenderBundleEncoderHandle DeviceCreateRenderBundleEncoder(DeviceHandle device, RenderBundleEncoderDescriptorFFI* descriptor);
public static extern RenderPipelineHandle DeviceCreateRenderPipeline(DeviceHandle device, RenderPipelineDescriptorFFI* descriptor);
public static extern Future DeviceCreateRenderPipelineAsync(DeviceHandle device, RenderPipelineDescriptorFFI* descriptor, CreateRenderPipelineAsyncCallbackInfoFFI callbackInfo);
public static extern SamplerHandle DeviceCreateSampler(DeviceHandle device, SamplerDescriptorFFI* descriptor);
public static extern ShaderModuleHandle DeviceCreateShaderModule(DeviceHandle device, ShaderModuleDescriptorFFI* descriptor);
public static extern TextureHandle DeviceCreateTexture(DeviceHandle device, TextureDescriptorFFI* descriptor);
public static extern void DeviceDestroy(DeviceHandle device);
public static extern Status DeviceGetAdapterInfo(DeviceHandle device, AdapterInfoFFI* adapterInfo);
public static extern void DeviceGetFeatures(DeviceHandle device, SupportedFeaturesFFI* features);
public static extern Status DeviceGetLimits(DeviceHandle device, Limits* limits);
public static extern Future DeviceGetLostFuture(DeviceHandle device);
public static extern QueueHandle DeviceGetQueue(DeviceHandle device);
public static extern WebGPUBool DeviceHasFeature(DeviceHandle device, FeatureName feature);
public static extern Future DevicePopErrorScope(DeviceHandle device, PopErrorScopeCallbackInfoFFI callbackInfo);
public static extern void DevicePushErrorScope(DeviceHandle device, ErrorFilter filter);
public static extern void DeviceSetLabel(DeviceHandle device, StringViewFFI label);
public static extern void DeviceAddRef(DeviceHandle device);
public static extern void DeviceRelease(DeviceHandle device);
````

## IWebGpuHandleNeedInstance

```
public interface IWebGpuHandleNeedInstance<TSelf, TSafeHandle> : IWebGpuHandle<TSelf>
    where TSelf : unmanaged, IWebGpuHandle<TSelf>
{
    public TSafeHandle? ToSafeHandle(Instance instance);
}
```

## IFromHandleWithInstance

```
public interface IFromHandleWithInstance<TSelf, THandle>
{
    public static abstract TSelf? FromHandle(THandle managedHandle, Instance instance);
    public static abstract Instance GetOwnerInstance(TSelf managedHandle);
}
```
