namespace d4net.Library;

public class DefaultDllGateway : IDllGateway
{
    private readonly IDllWrapper _dllWrapper;
    private readonly IJsonSerializer _jsonSerializer;

    public DefaultDllGateway(IDllWrapper dllWrapper, IJsonSerializer jsonSerializer) {
        _dllWrapper = dllWrapper;
        _jsonSerializer = jsonSerializer;
    }

    public Task<Response> CallEndpoint(EndpointInfo endpointInfo, object contextInfo, string? data) {
        Response response = new();

        void OnSuccess(string? data) {
            response.IsSuccess = true;
            response.Data = data;
        }

        void OnError(string? data) {
            response.IsSuccess = false;
            response.ErrorInfo = data != null ? _jsonSerializer.Deserialize<ErrorInfo>(data) : null;
        }

        _dllWrapper.Execute(endpointInfo, _jsonSerializer.Serialize(contextInfo), data, OnSuccess, OnError);

        return Task.FromResult(response);
    }
}