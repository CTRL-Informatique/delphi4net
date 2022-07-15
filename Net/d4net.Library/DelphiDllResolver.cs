using Microsoft.Extensions.DependencyInjection;

namespace d4net;

internal class DelphiDllResolver : IDelphiDllResolver
{
    private readonly IServiceProvider _serviceProvider;
    private readonly DelphiDllCollection _delphiDllCollection;

    public DelphiDllResolver(IServiceProvider serviceProvider, DelphiDllCollection delphiDllCollection) {
        _serviceProvider = serviceProvider;
        _delphiDllCollection = delphiDllCollection;
    }

    public IDelphiDll Resolve(string identifier) {
        var type = _delphiDllCollection.Get(identifier);
        var dll = _serviceProvider.GetRequiredService(type);
        return (IDelphiDll)dll;
    }
}