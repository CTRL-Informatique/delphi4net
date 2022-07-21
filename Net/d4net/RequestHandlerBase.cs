using System.Reflection;

namespace d4net;

public abstract class RequestHandlerBase : IRequestHandler
{
    private readonly IContextProvider _contextProvider;

    protected IJsonSerializer JsonSerializer { get; }

    public RequestHandlerBase(IContextProvider contextProvider, IJsonSerializer jsonSerializer) {
        _contextProvider = contextProvider;
        JsonSerializer = jsonSerializer;
    }

    public async Task HandleAsync(IRequest request) {
        var endpointInfo = GetEndpointInfo(request.GetType());
        var contextInfo = await _contextProvider.GetContextAsync();
        var requestData = JsonSerializer.Serialize(request);
        Log(endpointInfo, contextInfo, requestData);
        var response = await CallEndpoint(GetDllName(), endpointInfo, contextInfo, requestData);
        Log(response);
        ValidateResponse(response);
    }

    public async Task<T> HandleAsync<T>(IRequest<T> request) where T : class {
        var endpointInfo = GetEndpointInfo(request.GetType());
        var contextInfo = await _contextProvider.GetContextAsync();
        var requestData = JsonSerializer.Serialize(request);
        Log(endpointInfo, contextInfo, requestData);
        var response = await CallEndpoint(GetDllName(), endpointInfo, contextInfo, requestData);
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

    private string GetDllName() {
        return GetType().GetCustomAttribute<DllNameAttribute>()?.Value ?? "";
    }

    private EndpointInfo GetEndpointInfo(Type type) {
        var attr = type.GetCustomAttribute<EndpointAttribute>();

        if (attr == null)
            throw new Exception($"{typeof(EndpointAttribute)} missing on type {type}");

        return new() { MethodName = attr.Method, ServiceName = attr.Service };
    }
}