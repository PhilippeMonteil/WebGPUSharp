using System;
using System.Collections.Generic;
using System.Text;

using WebGpuSharp;

namespace _WebGpuSharp.Test
{
    internal class Temp
    {
        void Test0()
        {
            Surface? _s = null;
            _s?.GetHandle().Release();
        }
    }
}
