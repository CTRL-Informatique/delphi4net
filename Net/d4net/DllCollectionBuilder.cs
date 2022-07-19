using Microsoft.Extensions.DependencyInjection;

namespace d4net;

internal class DllCollectionBuilder : IDllCollectionBuilder
{
    private readonly DllCollection _dllCollection;
    private readonly IServiceCollection _serviceCollection;

    public DllCollectionBuilder(DllCollection dllCollection, IServiceCollection serviceCollection) {
        _dllCollection = dllCollection;
        _serviceCollection = serviceCollection;
    }

    public IDllCollectionBuilder Add<T>(string name = "") where T : class, IDllWrapper {
        _dllCollection.Add<T>(name);
        _serviceCollection.AddSingleton<T>();
        return this;
    }
}