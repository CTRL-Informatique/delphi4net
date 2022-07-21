using Microsoft.Extensions.DependencyInjection;

namespace d4net;

public class DllResolver
{
    private readonly IServiceProvider _serviceProvider;

    public DllResolver(IServiceProvider serviceProvider) {
        _serviceProvider = serviceProvider;
    }

    public IDllWrapper Resolve(string name) {
        return _serviceProvider.GetServices<IDllWrapper>().Single(x => x.Name == name);
    }
}