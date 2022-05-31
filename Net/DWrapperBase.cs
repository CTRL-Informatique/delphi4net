using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System.Runtime.InteropServices;

namespace D4Net;

public delegate void ResultAction([MarshalAs(UnmanagedType.BStr)] string result);

public delegate void LogAction(ushort level, [MarshalAs(UnmanagedType.BStr)] string message);

public abstract class DWrapperBase : IDWrapper
{
    private LogAction _logAction;
    private readonly ILogger<DWrapperBase> _logger;
    private readonly IJsonSerializer _jsonSerializer;

    protected DWrapperBase(ILogger<DWrapperBase> logger, IJsonSerializer jsonSerializer,
        IConfiguration configuration) {
        // Il faut garder une référence sur le callback sinon il se fait garbage collecter
        // Need to keep a reference to the delegates or they get garbage collected
        _logDelegate = Log;
        InvokeSetLogProc(_logDelegate);
        _logger = logger;
        _jsonSerializer = jsonSerializer;
    }

    public void Execute(EndpointInfo endpointInfo, ContextInfo contextInfo,
        string? requestData, Action<string?> successAction, Action<DalErrorInfo?> errorAction) {

        var contextString = _jsonSerializer.Serialize(contextInfo);

        void OnSuccess(string data) {
            successAction(data == "" ? null : data);
        }

        void OnError(string error) {
            var errorInfo = error == "" ? null : _jsonSerializer.Deserialize<ErrorInfo>(error);
            errorAction(errorInfo);
        }

        InvokeExecute(endpointInfo.ServiceName, endpointInfo.MethodName, contextString,
            requestData ?? "", OnSuccess, OnError);
    }

    protected virtual void InvokeSetLogProc(LogDelegate proc) { }

    protected virtual void InvokeExecute(string className, string methodName, string contextInfo, string requestData,
        ResultDelegate successAction, ResultDelegate errorAction) { }

    protected void Log(ushort level, string message) {
        switch (level) {
            case 0:
                break;

            case 1:
                _logger.LogWarning(message);
                break;

            case 2:
                _logger.LogInformation(message);
                break;

            default:
                _logger.LogDebug(message);
                break;
        }
    }
}
