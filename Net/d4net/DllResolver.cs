using Microsoft.Extensions.DependencyInjection;

namespace d4net;

public class DllResolver
{
    private readonly IServiceProvider _serviceProvider;

    public DllResolver(IServiceProvider serviceProvider) {
        _serviceProvider = serviceProvider;
    }

    public IDllWrapper Resolve(string name) {
        var dll = _serviceProvider.GetServices<IDllWrapper>().SingleOrDefault(x => x.Name == name);

        if (dll == null)
            throw new Exception($"No DLL with name '{name}'");

        return dll;
    }
}