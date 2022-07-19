using Castle.DynamicProxy;
using Microsoft.Extensions.DependencyInjection;

namespace d4net;

internal class D4NetBuilder : ID4NetBuilder
{
    private readonly IServiceCollection _serviceCollection;

    public D4NetBuilder(IServiceCollection serviceCollection) {
        _serviceCollection = serviceCollection;
    }

    public ID4NetBuilder AddDlls(Action<IDllCollectionBuilder> action) {
        var dllCollection = new DllCollection();
        _serviceCollection.AddSingleton(dllCollection);
        _serviceCollection.AddSingleton<IDllResolver, DllResolver>();
        var builder = new DllCollectionBuilder(dllCollection, _serviceCollection);
        action.Invoke(builder);
        return this;
    }

    public ID4NetBuilder AddDllServices(Action<IDllServiceCollectionBuilder> action) {
        _serviceCollection.AddSingleton<ProxyGenerator>();
        _serviceCollection.AddSingleton<Interceptor>();
        var builder = new DllServiceCollectionBuilder(_serviceCollection);
        action.Invoke(builder);
        return this;
    }

    public ID4NetBuilder UseContextProvider<T>() where T : class, IContextProvider {
        _serviceCollection.AddScoped<IContextProvider, T>();
        return this;
    }

    public ID4NetBuilder UseGateway<T>() where T : class, IGateway {
        _serviceCollection.AddSingleton<IGateway, T>();
        return this;
    }

    public ID4NetBuilder UseJsonSerializer<T>() where T : class, IJsonSerializer {
        _serviceCollection.AddSingleton<IJsonSerializer, T>();
        return this;
    }
}