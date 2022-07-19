using Castle.DynamicProxy;
using Microsoft.Extensions.DependencyInjection;

namespace d4net;

internal class DllServiceCollectionBuilder : IDllServiceCollectionBuilder
{
    private IServiceCollection _serviceCollection;

    public DllServiceCollectionBuilder(IServiceCollection serviceCollection) {
        _serviceCollection = serviceCollection;
    }

    public IDllServiceCollectionBuilder Add<T>() where T : class {
        _serviceCollection.AddSingleton(serviceProvider => {
            var proxyGenerator = serviceProvider.GetRequiredService<ProxyGenerator>();
            var interceptor = serviceProvider.GetRequiredService<Interceptor>();
            return proxyGenerator.CreateInterfaceProxyWithoutTarget<T>(interceptor.ToInterceptor());
        });
        return this;
    }
}