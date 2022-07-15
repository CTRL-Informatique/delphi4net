namespace d4net
{
    public class FakeGateway : IGateway
    {
        public static IGateway Gateway { get; set; } = null!;

        public async Task<Response> CallEndpoint(string dllName, EndpointInfo endpointInfo,
            object contextData, string? requestData) {
            return await Gateway.CallEndpoint(dllName, endpointInfo, contextData, requestData);
        }
    }
}