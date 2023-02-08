using Microsoft.Extensions.DependencyInjection;

namespace d4net;

public class DllResolver
{
    private readonly IServiceProvider _serviceProvider;

    public DllResolver(IServiceProvider serviceProvider) {
        _serviceProvider = serviceProvider;
    }

    public IDllWrapper Resolve(string name) {
        // on utilise ServiceProvider pour pas que les dlls soient loadés quand le service est instancié sinon
        // ça bloque le thread
        var dll = _serviceProvider.GetServices<IDllWrapper>().SingleOrDefault(x => x.Name == name);

        if (dll == null)
            throw new Exception($"No DLL with name '{name}'");

        return dll;
    }
}