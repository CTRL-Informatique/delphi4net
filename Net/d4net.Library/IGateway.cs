using Smigg.Common;

namespace d4net.Library;

public interface IGateway
{
    Task<Response> ExecuteRequest(EndpointInfo endpointInfo, object contextInfo,
        string? data);
}