namespace d4net;

public interface IDelphiDll
{
    void Execute(EndpointInfo endpointInfo, string? contextInfo, string? requestData,
        Action<string?> successAction, Action<string?> errorAction);
}