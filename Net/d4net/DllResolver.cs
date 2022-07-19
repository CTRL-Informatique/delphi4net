using Microsoft.Extensions.DependencyInjection;

namespace d4net;

internal class DllResolver : IDllResolver
{
    private readonly IServiceProvider _serviceProvider;
    private readonly DllCollection _delphiDllCollection;

    public DllResolver(IServiceProvider serviceProvider, DllCollection delphiDllCollection) {
        _serviceProvider = serviceProvider;
        _delphiDllCollection = delphiDllCollection;
    }

    public IDllWrapper Resolve(string identifier) {
        var type = _delphiDllCollection.Get(identifier);
        var dll = _serviceProvider.GetRequiredService(type);
        return (IDllWrapper)dll;
    }
}