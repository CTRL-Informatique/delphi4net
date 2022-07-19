/*
This interface allows to provide context data which each request sent to the dll, if no context data
is necessary, you can use the default provider which returns an empty object.
*/

namespace d4net;

public interface IContextProvider
{
    Task<object> GetContextAsync();
}