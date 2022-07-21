/*
This base implementation for the dll wrapper provides a basic framework for handling results and logging.
The abstract methods need to be overridden to invoke static methods marked with the [DllImport] attribute.
These methods can't be in the base class because the name of the dll file will vary from one application to
another.
*/

using System.Reflection;
using System.Runtime.InteropServices;

namespace d4net;

public delegate void LogAction(ushort level, [MarshalAs(UnmanagedType.BStr)] string message);

public delegate void ResultAction([MarshalAs(UnmanagedType.BStr)] string result);

public abstract class DllWrapperBase : IDllWrapper
{
    private LogAction _logAction;

    protected DllWrapperBase() {
        // Need to keep a reference to the delegates or they get garbage collected
        _logAction = Log;
        InvokeSetLogProc(_logAction);
    }

    public string Name => GetType().GetCustomAttribute<DllNameAttribute>()?.Value ?? "";

    public virtual void Execute(EndpointInfo endpointInfo, string? contextInfo,
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

    protected abstract void InvokeExecute(string serviceName, string methodName, string contextInfo, string requestData,
        ResultAction successAction, ResultAction errorAction);

    protected abstract void InvokeSetLogProc(LogAction action);

    protected virtual void Log(LogLevel level, string message) {
    }

    private void Log(ushort level, string message) {
        switch (level) {
            case 0:
                Log(LogLevel.Error, message);
                break;

            case 1:
                Log(LogLevel.Warning, message);
                break;

            case 2:
                Log(LogLevel.Info, message);
                break;

            default:
                Log(LogLevel.Error, message);
                break;
        }
    }
}