namespace d4net;

public class DefaultGateway : GatewayBase
{
    public DefaultGateway(IDelphiDllResolver delphiDllResolver, IJsonSerializer jsonSerializer) :
        base(delphiDllResolver, jsonSerializer) {
    }

    public override Task<Response> CallEndpoint(string dllName, EndpointInfo endpointInfo, object contextInfo, string? data) {
        Response response = new();

        void OnSuccess(string? data) {
            response.IsSuccess = true;
            response.Data = data;
        }

        void OnError(string? data) {
            response.IsSuccess = false;
            response.ErrorInfo = data != null ? JsonSerializer.Deserialize<ErrorInfo>(data) : null;
        }

        var dll = DllResolver.Resolve(dllName);
        dll.Execute(endpointInfo, JsonSerializer.Serialize(contextInfo), data, OnSuccess, OnError);

        return Task.FromResult(response);
    }
}