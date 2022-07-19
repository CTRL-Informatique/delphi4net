using Microsoft.Extensions.DependencyInjection;

namespace d4net;

public static class ServiceCollectionExtensions
{
    public static ID4NetBuilder AddDelphi4Net(this IServiceCollection serviceCollection) {
        serviceCollection.AddSingleton<IGateway, DefaultGateway>();
        serviceCollection.AddSingleton<IJsonSerializer, DefaultJsonSerializer>();
        serviceCollection.AddScoped<IContextProvider, DefaultContextProvider>();

        return new D4NetBuilder(serviceCollection);
    }
}