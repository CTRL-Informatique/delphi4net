using System.Runtime.InteropServices;
using Microsoft.Extensions.Logging;

namespace d4net.Library;

public delegate void LogAction(ushort level, [MarshalAs(UnmanagedType.BStr)] string message);

public delegate void ResultAction([MarshalAs(UnmanagedType.BStr)] string result);

public abstract class DllWrapperBase : IDllWrapper
{
    private LogAction _logAction;

    protected DllWrapperBase(IJsonSerializer jsonSerializer) {
        // Need to keep a reference to the delegates or they get garbage collected
        _logAction = Log;
        InvokeSetLogProc(_logAction);
    }

    public void Execute(EndpointInfo endpointInfo, string? contextInfo,
        string? requestData, Action<string?> successAction, Action<string?> errorAction) {
        void OnSuccess(string data) {
            successAction(data == "" ? null : data);
        }

        void OnError(string error) {
            errorAction(error == "" ? null : error);
        }

        InvokeExecute(endpointInfo.ServiceName, endpointInfo.MethodName, contextInfo ?? "",
            requestData ?? "", OnSuccess, OnError);
    }

    protected virtual void InvokeExecute(string serviceName, string methodName, string contextInfo, string requestData,
        ResultAction successAction, ResultAction errorAction) { }

    protected virtual void InvokeSetLogProc(LogAction action) {
    }

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