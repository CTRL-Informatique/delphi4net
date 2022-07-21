namespace d4net;

public interface IDllWrapper
{
    void Execute(EndpointInfo endpointInfo, string? contextInfo, string? requestData,
        Action<string?> successAction, Action<string?> errorAction);

    string Name { get; }
}