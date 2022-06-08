namespace d4net.Library;

public interface IContextProvider
{
    Task<object> GetContextAsync();
}