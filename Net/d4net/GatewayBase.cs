namespace d4net;

public abstract class GatewayBase : IGateway
{
    protected IDllResolver DllResolver { get; }
    protected IJsonSerializer JsonSerializer { get; }

    protected GatewayBase(IDllResolver delphiDllResolver, IJsonSerializer jsonSerializer) {
        DllResolver = delphiDllResolver;
        JsonSerializer = jsonSerializer;
    }

    public abstract Task<Response> CallEndpoint(string dllName, EndpointInfo endpointInfo,
        object contextData, string? requestData);
}