using Castle.DynamicProxy;
using System.Reflection;

namespace d4net;

//TODO add logging

public class Interceptor : AsyncInterceptorBase
{
    private readonly IGateway _gateway;
    private readonly IJsonSerializer _jsonSerializer;
    private readonly IContextProvider _contextProvider;

    public Interceptor(IGateway gateway, IJsonSerializer jsonSerializer,
        IContextProvider contextProvider) {
        _gateway = gateway;
        _jsonSerializer = jsonSerializer;
        _contextProvider = contextProvider;
    }

    protected override async Task InterceptAsync(IInvocation invocation,
        IInvocationProceedInfo proceedInfo, Func<IInvocation, IInvocationProceedInfo, Task> proceed) {
        var dllName = GetDllName(invocation);
        var endpointInfo = GetEndpointInfo(invocation);
        var contextInfo = await _contextProvider.GetContextAsync();
        var requestData = GetRequestData(invocation);
        var response = await _gateway.CallEndpoint(dllName, endpointInfo, contextInfo, requestData);
        ValidateResponse(response);
    }

    protected override async Task<TResult> InterceptAsync<TResult>(IInvocation invocation,
        IInvocationProceedInfo proceedInfo, Func<IInvocation, IInvocationProceedInfo, Task<TResult>> proceed) {
        var dllName = GetDllName(invocation);
        var endpointInfo = GetEndpointInfo(invocation);
        var contextInfo = await _contextProvider.GetContextAsync();
        var requestData = GetRequestData(invocation);
        var response = await _gateway.CallEndpoint(dllName, endpointInfo, contextInfo, requestData);
        ValidateResponse(response);
        var result = _jsonSerializer.Deserialize<TResult>(response.Data!);

        if (result == null)
            throw new DeserializationException(response.Data);

        return result;
    }

    private static void ValidateResponse(Response response) {
        if (!response.IsSuccess)
            throw new ResponseException(response.ErrorInfo!);
    }

    private EndpointInfo GetEndpointInfo(IInvocation invocation) {
        var type = invocation.Method.DeclaringType!;
        var serviceName = type.GetCustomAttribute<ServiceNameAttribute>()?.Name;

        if (serviceName == null)
            throw new Exception($"{typeof(ServiceNameAttribute)} missing on type {type}");

        var methodName = invocation.Method
            .GetCustomAttribute<MethodNameAttribute>()?.Name ?? invocation.Method.Name;

        return new() { ServiceName = serviceName, MethodName = methodName };
    }

    private string? GetRequestData(IInvocation invocation) {
        var firstArg = invocation.Arguments.FirstOrDefault();
        return firstArg == null ? null : _jsonSerializer.Serialize(firstArg);
    }

    private string GetDllName(IInvocation invocation) {
        var type = invocation.Method.DeclaringType!;
        var dllName = type.GetCustomAttribute<DllNameAttribute>()?.Value;

        if (dllName == null)
            throw new Exception($"{typeof(DllNameAttribute)} missing on type {type}");

        return dllName;
    }
}