/*
This interface is used to create an additional layer of abstraction between the interceptor
and the actual dll wrapper. This allows to provide a different implementation than the default
direct call implementation. For example, one could provide an implementation which uses http
or rpc calls.
It also allows to interact with multiple delphi dlls by resolving a dll wrapper instance associated
with a name.
*/

namespace d4net;

public interface IGateway
{
    Task<Response> CallEndpoint(string dllName, EndpointInfo endpointInfo, object contextData,
        string? requestData);
}