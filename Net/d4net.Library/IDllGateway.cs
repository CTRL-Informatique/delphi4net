namespace d4net.Library;

public interface IDllGateway
{
    Task<Response> CallEndpoint(EndpointInfo endpointInfo, object contextInfo,
        string? data);
}