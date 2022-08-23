using System.Reflection;

namespace d4net;

public abstract class RequestSenderBase : IRequestSender
{
    private readonly IContextProvider _contextProvider;

    protected IJsonSerializer JsonSerializer { get; }

    public RequestSenderBase(IContextProvider contextProvider, IJsonSerializer jsonSerializer) {
        _contextProvider = contextProvider;
        JsonSerializer = jsonSerializer;
    }

    public async Task Send(IRequest request, string dllName) {
        var endpointInfo = GetEndpointInfo(request.GetType());
        var contextInfo = await _contextProvider.GetContextAsync();
        OnGetContextInfo(contextInfo, dllName);
        var requestData = JsonSerializer.Serialize(request);
        Log(endpointInfo, contextInfo, requestData);
        var response = await CallEndpoint(dllName, endpointInfo, contextInfo, requestData);
        Log(response);
        ValidateResponse(response);
    }

    public async Task<T> Send<T>(IRequest<T> request, string dllName) where T : class {
        var endpointInfo = GetEndpointInfo(request.GetType());
        var contextInfo = await _contextProvider.GetContextAsync();
        OnGetContextInfo(contextInfo, dllName);
        var requestData = JsonSerializer.Serialize(request);
        Log(endpointInfo, contextInfo, requestData);
        var response = await CallEndpoint(dllName, endpointInfo, contextInfo, requestData);
        Log(response);
        ValidateResponse(response);
        var result = JsonSerializer.Deserialize<T>(response.Data!);

        if (result == null)
            throw new DeserializationException(response.Data);

        return result;
    }

    protected abstract Task<Response> CallEndpoint(string dllName, EndpointInfo endpointInfo, object contextInfo, string? data);

    protected virtual void Log(EndpointInfo endpointInfo, object contextInfo, string? requestData) {
    }

    protected virtual void Log(Response response) {
    }

    private static void ValidateResponse(Response response) {
        if (!response.IsSuccess)
            throw new ResponseException(response.ErrorInfo!);
    }

    private EndpointInfo GetEndpointInfo(Type type) {
        var attr = type.GetCustomAttribute<EndpointAttribute>();

        if (attr == null)
            throw new Exception($"{typeof(EndpointAttribute)} missing on type {type}");

        return new() { MethodName = attr.Method, ServiceName = attr.Service };
    }

    protected virtual void OnGetContextInfo(object contextInfo, string dllName) {
    }
}