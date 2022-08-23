using Microsoft.Extensions.DependencyInjection;

namespace d4net;

internal class D4NetBuilder : ID4NetBuilder
{
    private readonly IServiceCollection _serviceCollection;

    public D4NetBuilder(IServiceCollection serviceCollection) {
        _serviceCollection = serviceCollection;
    }

    public ID4NetBuilder AddDll<T>() where T : class, IDllWrapper {
        _serviceCollection.AddSingleton<IDllWrapper, T>();
        return this;
    }

    public ID4NetBuilder AddRequestSender<T>() where T : class, IRequestSender {
        _serviceCollection.AddScoped<IRequestSender, T>();
        return this;
    }

    public ID4NetBuilder UseContextProvider<T>() where T : class, IContextProvider {
        _serviceCollection.AddScoped<IContextProvider, T>();
        return this;
    }

    public ID4NetBuilder UseJsonSerializer<T>() where T : class, IJsonSerializer {
        _serviceCollection.AddSingleton<IJsonSerializer, T>();
        return this;
    }
}