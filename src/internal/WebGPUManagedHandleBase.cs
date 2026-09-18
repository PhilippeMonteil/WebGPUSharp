using System.Runtime.CompilerServices;
using WebGpuSharp.FFI;

namespace WebGpuSharp.Internal;

public abstract class WebGPUManagedHandleBase<THandle> :
    IEquatable<WebGPUManagedHandleBase<THandle>>,
    IEquatable<THandle>,
    IDisposable
    where THandle : unmanaged, IEquatable<THandle>, IWebGpuHandle<THandle>
{
    private readonly WebGpuSafeHandle<THandle> _safeHandle;

    protected THandle Handle
    {
        [MethodImpl(MethodImplOptions.AggressiveInlining)]
        get => _safeHandle.Handle;
    }

    #region --- IDisposable

    int m_disposed;

    void dispose(bool disposing)
    {
        int _disposed = Interlocked.CompareExchange(ref m_disposed, 1, 0);
        if (_disposed != 0) return;
        _safeHandle?.Dispose();
    }

    ~WebGPUManagedHandleBase()
    {
        dispose(false);
    }

    public void Dispose()
    {
        GC.SuppressFinalize(this);
        dispose(true);
    }

    #endregion

    protected WebGPUManagedHandleBase(THandle handle)
    {
        _safeHandle = new WebGpuSafeHandle<THandle>(handle);
    }

    [MethodImpl(MethodImplOptions.AggressiveInlining)]
    internal THandle GetHandle()
    {
        return _safeHandle.Handle;
    }

    [MethodImpl(MethodImplOptions.AggressiveInlining)]
    public bool Equals(WebGPUManagedHandleBase<THandle>? other)
    {
        return other != null && Handle.Equals(other.Handle);
    }


    [MethodImpl(MethodImplOptions.AggressiveInlining)]
    public bool Equals(THandle other)
    {
        return Handle.Equals(other);
    }

    [MethodImpl(MethodImplOptions.AggressiveInlining)]
    public static bool operator ==(WebGPUManagedHandleBase<THandle>? left, WebGPUManagedHandleBase<THandle>? right) =>
        ReferenceEquals(left, right) || (left?.Equals(right) ?? false);

    [MethodImpl(MethodImplOptions.AggressiveInlining)]
    public static bool operator !=(WebGPUManagedHandleBase<THandle>? left, WebGPUManagedHandleBase<THandle>? right) =>
        !(left == right);

    [MethodImpl(MethodImplOptions.AggressiveInlining)]
    public override bool Equals(object? obj)
    {
        if (obj is WebGPUManagedHandleBase<THandle> other)
        {
            return Equals(other);
        }

        return false;
    }

    public override int GetHashCode()
    {
        return Handle.GetHashCode();
    }
}
