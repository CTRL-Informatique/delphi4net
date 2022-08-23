namespace d4net;

public class DefaultRequestHandler : RequestSenderBase
{
    private DllResolver _dllResolver;

    public DefaultRequestHandler(IContextProvider contextProvider, IJsonSerializer jsonSerializer, DllResolver dllResolver) :
        base(contextProvider, jsonSerializer) {
        _dllResolver = dllResolver;
    }

    protected override Task<Response> CallEndpoint(string dllName, EndpointInfo endpointInfo, object contextInfo, string? data) {
        Response response = new();

        void OnSuccess(string? data) {
            response.IsSuccess = true;
            response.Data = data;
        }

        void OnError(string? data) {
            response.IsSuccess = false;
            response.ErrorInfo = data != null ? JsonSerializer.Deserialize<ErrorInfo>(data) : null;
        }

        var dll = _dllResolver.Resolve(dllName);
        dll.Execute(endpointInfo, JsonSerializer.Serialize(contextInfo), data, OnSuccess, OnError);

        return Task.FromResult(response);
    }
}