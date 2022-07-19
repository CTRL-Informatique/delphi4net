using Castle.DynamicProxy;
using Microsoft.Extensions.DependencyInjection;

namespace d4net;

internal class D4NetBuilder : ID4NetBuilder
{
    private readonly DelphiDllCollection _dllCollection;
    private readonly IServiceCollection _serviceCollection;

    public D4NetBuilder(IServiceCollection serviceCollection, DelphiDllCollection dllCollection) {
        _serviceCollection = serviceCollection;
        _dllCollection = dllCollection;
    }

    public ID4NetBuilder AddDelphiDll<T>(string name) where T : class, IDelphiDll {
        _dllCollection.Add<T>(name);
        _serviceCollection.AddSingleton<T>();
        return this;
    }

    public ID4NetBuilder AddDelphiService<T>() where T : class {
        _serviceCollection.AddSingleton(serviceProvider => {
            var proxyGenerator = serviceProvider.GetRequiredService<ProxyGenerator>();
            var interceptor = serviceProvider.GetRequiredService<Interceptor>();
            return proxyGenerator.CreateInterfaceProxyWithoutTarget<T>(interceptor.ToInterceptor());
        });
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