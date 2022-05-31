namespace D4Net;

public interface IDWrapper
{
    void Execute(EndpointInfo endpointInfo, ContextInfo contextInfo, string? requestData,
        Action<string?> successAction, Action<DalErrorInfo?> errorAction);
}
