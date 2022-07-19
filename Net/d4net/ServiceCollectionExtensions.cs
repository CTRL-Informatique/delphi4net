using Castle.DynamicProxy;
using Microsoft.Extensions.DependencyInjection;

namespace d4net;

public static class ServiceCollectionExtensions
{
    public static ID4NetBuilder AddDelphi4Net(this IServiceCollection serviceCollection) {
        var dllCollection = new DelphiDllCollection();
        serviceCollection.AddSingleton(dllCollection);
        serviceCollection.AddSingleton<IDelphiDllResolver, DelphiDllResolver>();
        serviceCollection.AddSingleton<IGateway, DefaultGateway>();
        serviceCollection.AddSingleton<IJsonSerializer, DefaultJsonSerializer>();
        serviceCollection.AddScoped<IContextProvider, DefaultContextProvider>();
        serviceCollection.AddSingleton<ProxyGenerator>();
        serviceCollection.AddSingleton<Interceptor>();
        return new D4NetBuilder(serviceCollection, dllCollection);
    }
}